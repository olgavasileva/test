class Scene < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :studio
  has_many :gallery_elements, :dependent => :destroy
  mount_uploader :image, SceneImageUploader

  def self.factory user, scene_data, studio, canvas_height=nil, canvas_width=nil, gallery_id=nil, image=nil
    Scene.new.process user, scene_data, studio, canvas_height=nil, canvas_width=nil, gallery_id=nil, image=nil
  end

  def process(user, scene_data, studio, canvas_height=nil, canvas_width=nil, gallery_id=nil, image=nil)
    self.user = user if self.user.nil?
    data = scene_data.gsub(/\s+/, "")
    data = scale_data(data, canvas_height, canvas_width) if (canvas_height && canvas_width)
    self.canvas_json = data
    data_errors = self.scene_data_errors
    raise Exception.new(data_errors) if data_errors.any?
    self.studio = studio
    image_filename = self.save_image(image)
    self.save
    #FileUtils.rm(image_filename) rescue nil
    self.add_to_gallery(Gallery.my_gallery(user))
    (self.add_to_gallery(Gallery.find(params[:gallery_id])) rescue nil) unless gallery_id.nil?
    self
  end

  def save_image(image_data)
    image_data = generate_image unless image_data
    image_filename = Time.now.to_i.to_s + ".png"
    File.open(image_filename, "wb") do |f|
      f.write(image_data)
    end
    self.image = File.open(image_filename)
    image_filename
  end

  def generate_image
    require 'net/http'
    http = Net::HTTP.new('localhost', 8124)
    begin
      image_data = http.post('/', self.fabric_json).body
    rescue Exception => ex
      Rails.logger.error("Exception generating image for scene: #{ex.message}")
    end
  end

  def api_format_to_fabric(obj)
    base = {
        'angle' => obj['rotation'], 'clipTo' => nil, 'fill' => "rgb(0,0,0)", 'filters' => [], 'flipX' => obj['flipped'],
        'flipY' => false, 'hasBorders' => true, 'hasControls' => true, 'hasRotatingPoint' => true,
        'height' => obj['height'], 'left' => obj['x'], 'opacity' => 1, 'originX' => obj['originX'],
        'originY' => obj['originY'], 'overlayFill' => nil, 'perPixelTargetFind' => false, 'scaleX' => obj['scale'],
        'scaleY' => obj['scale'], 'selectable' => true, 'shadow' => nil, 'stroke' => nil, 'strokeDashArray' => nil,
        'strokeLineCap' => "butt", 'strokeLineJoin' => "miter", 'strokeMiterLimit' => 10, 'strokeWidth' => 1,
        'top'=> obj['y'], 'transparentCorners' => true, 'visible' => true, 'width' => obj['width']
    }

    if obj['is_group']
      base['type'] = "group";
      objectsSorted = obj['objects'].sort_by{|e| e['z_index']}
      base['objects'] = []
      objectsSorted.each do |object|
        base['objects'] << api_format_to_fabric(object)
      end
      base['psOrigWidth'] = obj['width'] * obj['scale']
      base['psOrigHeight'] = obj['height'] * obj['scale']
    else
      item = eval(obj['type'] || 'Sticker').find(obj['id']) rescue return
      base['type'] = "image"
      if obj['type'] == 'GarmentSticker' && item.sticker_image_location
        base['src'] = item.sticker_image_location
      elsif item.image_url
        base['src'] = item.image_url
      else
        # If there's no image, don't bother returning anything
        return
      end
      base['psItemId'] = item.id
      base['psType'] = item.class.to_s
      base['psOrigWidth'] = item.image_width
      base['psOrigHeight'] = item.image_height
    end
    return base
  end

  # Convert the canvas_json into JSON that can be loaded into fabric.js
  def fabric_json(json=canvas_json)
    result = {'objects' => []}
    scene_json = JSON.parse(json)
    if scene_json['objects'].any?
      objectsSorted = scene_json['objects'].sort_by{|e| e['z_index'].to_i}
      objectsSorted.each do |object|
        result['objects'] << api_format_to_fabric(object)
      end
    end
    if scene_json['backgrounds'] && scene_json['backgrounds'].any?
      background = Sticker.find(scene_json['backgrounds'][0]['id']) rescue return
      result['backgroundImage'] = background.image_url
      result['backgroundImageOpacity'] = 1
      result['backgroundImageStretch'] = true
    end
    return result.to_json
  end

  # Add the scene to the given gallery.  Return nil if the scene already exists in the gallery,
  # return the new gallery entry otherwise
  def add_to_gallery(gallery)
    existing_element = GalleryElement.where('scene_id = ? AND gallery_id = ?', id, gallery.id).take
    # Already in gallery, return nil
    return nil if existing_element
    if gallery.contest?
      return nil if user.nil?
      existing_entry = GalleryElement.where('user_id = ? AND gallery_id = ?', user.id, gallery.id).first
      if existing_entry
        # User already entered in contest, return false
        return nil
      end
    end
    return GalleryElement.add(gallery, self)
  end

  def confirm_objects_exist(objects)
    errors = []
    objects.each { |obj|
      begin
        if obj['is_group']
          errors << confirm_objects_exist(obj['objects'])
        else
          eval(obj['type'] || 'Sticker').find(obj['id'])
        end
      rescue
        errors << ["No #{eval(obj['type'] || 'Sticker')} with ID #{obj['id']}"]
      end
    }

    return errors
  end

  def scene_data_errors
    scene_json = JSON.parse(canvas_json)
    errors = []
    if scene_json['objects'].any?
      confirm_objects_exist(scene_json['objects'])
    end
    if scene_json['backgrounds'] && scene_json['backgrounds'].any?
      begin
        Sticker.find(scene_json['backgrounds'][0]['id'])
      rescue
        errors << ["No background with ID #{scene_json['backgrounds'][0]['id']}"]
      end
    end

    return errors
  end

  def stickers(type=nil)
    scene_stickers = []
    canvas_info = JSON.parse(self.canvas_json)
    get_stickers(canvas_info['objects'], scene_stickers, type)
    scene_stickers.map{|ss| ss.to_builder.attributes!}
  end

  def share_link(type, share_user = nil)
    return "" if user.nil?
    url = Rails.application.routes.url_helpers.profile_show_item_url(:username => user.login, :item_type => 'scene', :item_id => id, :host => APP_CONFIG[:site_url])
    uid = (share_user ? share_user.id : 0)
    # Temporarily don't add tracking info to text messages because it makes the URL too long and splits it into 2 messages.
    return (url + "?referral=#{uid}") if type == 'txt'
    studio_name = studio_configuration.name.gsub(" ", "_")
    return url + "?f=share_#{type}_#{studio_name}_scene&utm_source=share&utm_medium=#{type}_share&utm_campaign=#{studio_name}&utm_content=scene&referral=#{uid}"
  end

  def scale_object(object, scale_factor)
    object.nil? ? nil : (object * scale_factor).round(0)
  end

  def scale_objects(data, scale_factor)
    data['objects'].each do |object|
      ['x', 'y', 'width', 'height'].each do |prop|
        object[prop] = scale_object(object[prop], scale_factor)
      end
      if object['is_group']
        scale_objects(object, scale_factor)
      end
    end
  end

  def scale_data(raw_data, canvas_height, canvas_width)
    scale_factor = get_scale_factor(canvas_height, canvas_width)
    data = JSON.parse(raw_data)
    scale_objects(data, 1 / scale_factor)
    return data.to_json
  end

  private

  def get_stickers(objects, container, type=nil)
    objects.each do |sticker|
      if sticker['objects']
        get_stickers(sticker['objects'], container, type)
      else
        next if type && sticker['type'] != type
        (container << eval(sticker['type'] || 'Sticker').find(sticker['id'])) rescue next
      end
    end
  end

  MAX_CANVAS_HEIGHT ||= 1408
  MAX_CANVAS_WIDTH ||= 2048

  BASE_CANVAS_HEIGHT ||= 495
  BASE_CANVAS_WIDTH ||= 720

  def get_scale_factor(height, width)
    errors = []
    errors << 'You must provide a canvas height' if height.nil?
    errors << 'You must provide a canvas width' if width.nil?
    raise Exception.new(errors) if errors.any?

    # We're expecting the width to be greater than the height.  If it's the other way around, switch
    # the two dimensions
    switched = false
    if height.to_f > width.to_f
      temp = height
      height = width
      width = temp
      switched = true
    end

    return (height.to_f / BASE_CANVAS_HEIGHT).round(4)
  end
end
