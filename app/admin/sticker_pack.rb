ActiveAdmin.register StickerPack do
  menu parent: 'Studios', priority: 15
  actions :index, :show, :new, :create, :edit, :update
  batch_action :destroy, false

  # Never trust parameters from the scary internet, only allow the white list through.
  permit_params  :display_name, :starts_at, :expires_at, :disabled, :klass, :inclusive,
                 :starts_at_date, :starts_at_time_hour, :starts_at_time_minute, :expires_at_date,
                 :expires_at_time_hour, :expires_at_time_minute, :lock_id, :header_icon,
                 :footer_image, :footer_link, :max_on_canvas, menu_ids: [], studio_configuration_ids: [], new_sticker_ids: []

  #Index scopes
  scope :all, default: true
  scope :active
  scope :disabled
  scope :expired

  #Sidebar
  filter :display_name
  #filter :tags, label: 'Categories', as: :select, collection: ActsAsTaggableOn::Tag.where(taggings: {taggable_type: %w(Sticker Background), context: 'categories'}).joins(:taggings).uniq.map{|t| [t.name, t.id]}, input_html: {class: 'chosen-select-sidebar'}
  #filter :menu, collection: Menu.all.map {|m| [m.name, m.id]}, input_html: {class: 'chosen-select-sidebar'}
  filter :studios, collection: proc { Studio.all.map {|m| [m.name, m.id]} }, input_html: {class: 'chosen-select-sidebar'}
  filter :stickers, collection: proc { Sticker.all.map {|m| [m.display_name, m.id]} }, input_html: {class: 'chosen-select-sidebar'}
  filter :starts_at
  filter :expires_at

  #Index page
  index do
    column :display_name
    column :disabled, sortable: :disabled  do |pack|
      pack.disabled? ? 'Disabled' : 'Active'
    end
    column :starts_at
    column :expires_at
    actions do |pack|
      links = ''.html_safe
      links << link_to('Copy', copy_admin_sticker_pack_path(pack), class: 'member_link')
      if pack.disabled?
        links << link_to('Activate', activate_admin_sticker_pack_path(pack), method: :patch, class: 'member_link')
      else
        links << link_to('Disable', disable_admin_sticker_pack_path(pack), method: :patch, class: 'member_link')
      end

      # links << link_to('Stickers',  stickers_admin_sticker_pack_path(pack), class: 'member_link')
      links
    end
  end

  #Form for New/Edit
  form do |f|
    f.inputs 'Stickers' do
      f.template.render partial: 'show_stickers', locals: {sticker_pack: f.object}
    end

    f.inputs do
      f.input :display_name, hint: 'What the Users will see'
      f.input :header_icon, as: :file, hint: f.template.image_tag(f.object.header_icon_url.to_s)
      f.input :footer_image, as: :file, hint: f.template.image_tag(f.object.footer_image_url.to_s)
      f.input :footer_link
      f.input :max_on_canvas, hint: 'Maximum number of sticker from this pack allowed on the canvas at once.  Leave blank for unlimited.'
      f.input :disabled
      f.input :starts_at, :as => :just_datetime_picker
      f.input :expires_at, :as => :just_datetime_picker
    end

    f.inputs 'Associations' do
      f.input :studio_ids,
              label: 'Studios',
              as: :check_boxes,
              collection: Studio.all.map{|sc| [" #{sc.name}( #{sc.display_name}) ", sc.id]}
    end
    f.actions
  end

  show do |sp|
    panel 'Stickers' do
      render partial: 'show_stickers', locals: {sticker_pack: sp}
    end

    attributes_table do
      row :name
      row :header_icon_url
      row :header_icon do
        image_tag(sp.header_icon_url.to_s)
      end
      row :footer_image_url
      row :footer_image do
        image_tag(sp.footer_image_url.to_s)
      end
      row :footer_link
      row :max_on_canvas
      row :disabled do
        sp.disabled? ? 'Disabled' : 'Active'
      end
      rows :starts_at, :expires_at, :created_at, :updated_at
    end

    panel 'Associations' do
      attributes_table_for sp do
        row :studios do
          sp.studios.map {|sc| link_to("#{sc.display_name} (#{sc.name})", admin_studio_configuration_path(sc))}.join(", ").html_safe
        end
      end
    end
  end

  #Controller methods
  controller do

    def new
      if params[:id]
        begin
          sp = StickerPack.find(params[:id])
          @sticker_pack = StickerPack.new(sp.attributes.except(:id, :menu_id))
          @sticker_pack.display_name += '(copy)'
        rescue
          @sticker_pack = StickerPack.new
        end
      else
        @sticker_pack = StickerPack.new
      end
    end

    def update (options={}, &block)
      sticker_pack = StickerPack.find(params[:id])
      # If the sticker pack has been removed from a studio, touch the studio so the mobile app will know it needs to update
      sticker_pack.studios.each do |studio|
        unless params[:sticker_pack][:studio_ids].include?(studio.id.to_s)
          studio.touch
          studio.save
        end
      end
      super
    end
  end

  #Member actions
  member_action :activate,  method: :patch do
    pack = StickerPack.find(params[:id])
    pack.activate!
    redirect_to action: :index
  end

  member_action :disable,  method: :patch do
    pack = StickerPack.find(params[:id])
    pack.disable!
    redirect_to action: :index
  end

  member_action :stickers, method: :get do
    @sticker_pack = StickerPack.find(params[:id])
    if(params[:category] == "all")
      if params[:sticker_pack_status] == "unplaced"
        @stickers = Sticker.available.where("id not in (select sticker_id from sticker_pack_stickers)")
      else
        @stickers = Sticker.available
      end
    elsif(params[:category])
      @stickers = Sticker.tagged_with(params[:category])
      @current_category = params[:category]
    else
      @stickers = []
    end
    @categories = ActsAsTaggableOn::Tag.joins(:taggings).where(taggings: {taggable_type: Sticker::TYPES}).uniq
  end

  member_action :sort_stickers, method: :post do
    begin
      sticker_pack = StickerPack.find(params[:id])
      if params[:sticker_ids]
        params[:sticker_ids].each_with_index do |id, idx|
          sticker_pack.sticker_pack_stickers.where(sticker_id: id).first.update_attribute(:sort_order, idx)
        end
      end
      if params[:background_ids]
        params[:background_ids].each_with_index do |id, idx|
          sticker_pack.sticker_pack_stickers.where(sticker_id: id).first.update_attribute(:sort_order, idx)
        end
      end
      if params[:add_stickers]
        params[:add_stickers].each do |id|
          sticker = Sticker.find(id)
          if !sticker_pack.stickers.include?(sticker)
            sticker_pack.stickers << sticker
          end
        end
        sticker_pack.touch
        sticker_pack.save
      end
      if params[:remove_stickers]
        params[:remove_stickers].each do |id|
          sticker_pack.stickers.delete(Sticker.find(id))
        end
        sticker_pack.touch
        sticker_pack.save
      end
      render js: "window.location = '" + stickers_admin_sticker_pack_path(sticker_pack) + "'"
    rescue Exception => e
      render js: "$('#sticker_save_response').removeClass('success').addClass('error').html('Couldn't find Sticker Pack, please refresh page and try again.);"
    end
  end

  member_action :sort_tags, method: :patch do
    @sticker_pack = StickerPack.find(params[:id])
    success = true
    params[:taggings].each_pair do |tagging_id, value|
      unless @sticker_pack.sticker_pack_taggings.find(tagging_id).update_attribute(:weight, value)
        success = false
      end
    end

    if success
      flash[:notice] = "Successfully updated #{@sticker_pack.display_name} weights."
    else
      flash[:error] = "An error occurred. Please try again, or notify Tech."
    end
    redirect_to :action => :show
  end

  member_action :copy, method: :get do
    redirect_to action: :new, id: params[:id]
  end

  action_item only: :show do
    link_to('Copy', copy_admin_sticker_pack_path(sticker_pack))
  end

  action_item only: :show do
    link_to('Stickers', stickers_admin_sticker_pack_path(sticker_pack))
  end
end
