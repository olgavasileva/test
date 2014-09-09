require 'csv'

ActiveAdmin.register Sticker do
  menu :parent => 'Studios', :priority => 20
  config.sort_order = 'priority ASC'
  actions :index, :show, :new, :create, :edit, :update
  batch_action :destroy, false

  #Index scopes
  scope :all, :default => true
  scope :disabled
  scope :backgrounds
  scope :stickers

  #Sidebar
  filter :display_name
  filter :categories, :as => :select, :collection => proc { ActsAsTaggableOn::Tag.joins(:taggings).where(:taggings => {:taggable_type => Sticker::TYPES}).uniq }, :input_html => {:class => 'chosen-select-sidebar'}
  filter :sticker_packs, :collection => proc { StickerPack.all.map {|m| [m.display_name, m.id]} }, :input_html => {:class => 'chosen-select-sidebar'}

  #Index page
  index :as => :grid, :columns => 5 do |sticker|
    content_tag :div, :class => "sticker-grid #{if sticker.disabled? then 'disabled' end}" do
      div = link_to(image_tag(sticker.image.thumb.url), admin_sticker_path(sticker))
      div << content_tag(:p, sticker.display_name)
      div << link_to('Edit', edit_admin_sticker_path(sticker))
      if sticker.disabled?
        active_link = link_to('Activate', activate_admin_sticker_path(params.except(:action, :controller).merge(:id => sticker.id)), :method => :patch)
      else
        active_link = link_to('Disable', disable_admin_sticker_path(params.except(:action, :controller).merge(:id => sticker.id)), :method => :patch)
      end
      div << content_tag(:p, active_link)
      div
    end
  end

  #Form for New/Edit
  form do |f|
    f.inputs do
      f.input :display_name, hint: 'What the Users will see'
      f.input :priority
      f.input :disabled
      f.input :type, as: :select, collection: Sticker::TYPES, include_blank: false
      f.input :tag_list,
        collection: ActsAsTaggableOn::Tag.where(taggings: {taggable_type: %w(Sticker Background), context: 'tags'}).joins(:taggings).uniq.map(&:name),
        hint: 'For Marketing use',
        as: :check_boxes
      f.input :mirrorable
      f.input :spotlightable

      f.input :sticker_pack_ids,
        label: 'Sticker Packs',
        collection: StickerPack.all,
        member_label: :display_name,
        as: :check_boxes

      f.has_many :item_properties, heading: 'Properties', allow_destroy: true, new_record: "New Property" do |p|
        p.input :key, collection: ([p.object.key] + Key.order(:key).map(&:key)).uniq
        p.input :value
      end

      f.input :image, as: :file, hint: f.template.image_tag(f.object.image_url.to_s)

      f.actions
    end
  end

  # form :partial => 'form'

  show do |s|
    attributes_table do
      row :image do
        image_tag(s.image_url.to_s)
      end
      row :display_name
      rows :type, :priority
      row :disabled do
        s.disabled? ? 'Disabled' : 'Active'
      end
      rows :spotlightable, :mirrorable, :category_list, :tag_list

      row :created_at
      row :updated_at
    end

    panel 'Associations' do
      attributes_table_for s do
        row :sticker_packs do
          s.sticker_packs.map {|sp| (link_to "#{sp.display_name}", admin_sticker_pack_path(sp))}.join(', ').html_safe
        end
      end
    end

    panel 'Properties' do
      attributes_table_for :item_properties do
        s.item_properties.each do |prop|
          row prop.key.to_sym do
            prop.value
          end
        end
      end
    end

  end

  #Controller methods
  controller do
    # Never trust parameters from the scary internet, only allow the white list through.
    def permitted_params
      params.permit(:id, :sticker => [:display_name, :type, :mirrorable, :priority, :disabled,
                                      :created_at, :updated_at, :image, :spotlightable, :category_list => [],
                                      :tag_list => [], :sticker_pack_ids => [],
                                      :item_properties_attributes => [:id, :key ,:value, :item_id, :item_type, :_destroy]])
    end

    def update (options={}, &block)
      sticker = Sticker.find(params[:id])
      # If the sticker has been removed from a sticker pack, touch the sticker pack so the mobile app will know it needs to update
      old_sticker_pack_ids = []
      sticker.sticker_packs.each do |sticker_pack|
        unless params[:sticker][:sticker_pack_ids].include?(sticker_pack.id.to_s)
          sticker_pack.touch
          sticker_pack.save
          old_sticker_pack_ids << sticker_pack.id.to_s
        end
      end
      # If the sticker has been added to a sticker pack, touch the sticker pack so the mobile app will know it needs to update
      params[:sticker][:sticker_pack_ids].each do |new_sticker_pack_id|
        next if new_sticker_pack_id.blank?
        unless old_sticker_pack_ids.include?(new_sticker_pack_id)
          new_sticker_pack = StickerPack.find(new_sticker_pack_id)
          new_sticker_pack.touch
          new_sticker_pack.save
        end
      end
      super
    end
  end

  #Member actions
  member_action :activate,  :method => :patch do
    sticker = Sticker.find(params[:id])
    sticker.activate!
    redirect_to :action => :index, :order => params[:order], :page => params[:page], :scope => params[:scope], :q => params[:q]
  end

  member_action :disable,  :method => :patch do
    sticker = Sticker.find(params[:id])
    sticker.disable!
    redirect_to :action => :index, :order => params[:order], :page => params[:page], :scope => params[:scope], :q => params[:q]
  end

  collection_action :import, :method => [:get, :post] do
    @error = ''
    @ignored = 0
    @updated = 0
    @success = 0
    if params[:file]
      data = params[:file].read
      CSV.parse(data, :headers => true, :header_converters => :symbol) do |line|
        if Sticker.where(:id => line[:id]).empty?
          s = Sticker.new
          begin
            attr = line.to_hash.except(:path_to_image, :id, :property_list)

            s = Sticker.new(attr)

            unless line[:path_to_image].blank?
              path_to_file = "#{Rails.root}/lib/stickers/#{line[:path_to_image].gsub('./', '')}"
              if File.exists?(path_to_file)
                s.image = File.open(path_to_file)
              end
            end

            s.save!

            @success += 1
          rescue
            @error = "Error with #{line[:display_name] || 'sticker'}"
            @error_messages = s.errors.full_messages
            break
          end
        else
          if params[:update_existing]
            sticker = Sticker.find(line[:id])
            begin
              attr = line.to_hash.except(:path_to_image, :id, :property_list)

              unless line[:path_to_image].blank?
                path_to_file = "#{Rails.root}/lib/stickers/#{line[:path_to_image].gsub('./', '')}"
                if File.exists?(path_to_file)
                  sticker.image = File.open(path_to_file)
                end
              end

              sticker.update_attributes!(attr)
              @updated += 1
            rescue
              @error = "Error updating (#{line[:id]})#{line[:display_name] || 'sticker'}"
              @error_messages = sticker.errors.full_messages
              break
            end
          else
            @ignored += 1
            next
          end
        end
      end
      if @error.blank?
        flash[:notice] = "Uploaded #{@success} Stickers!"
        flash[:notice] << " Ignored #{@ignored} entries as duplicates." if @ignored > 0
        flash[:notice] << " Updated #{@updated} entries." if @updated > 0
      else
        flash[:error] = @error
      end
      params[:file].tempfile = nil rescue nil
    end
  end

  action_item :only => :index do
    link_to('Import CSV', import_admin_stickers_path)
  end

  csv do
    column :id
    column :display_name
    column :priority
    column :type
    column :disabled
    column :category_list
    column :tag_list
    column :mirrorable
    column :spotlightable
  end
end
