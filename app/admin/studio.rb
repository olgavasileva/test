ActiveAdmin.register Studio do
  menu parent: 'Studios', priority: 5
  actions :index, :show, :new, :create, :edit, :update, :delete
  batch_action :destroy, false

  #Index scopes
  scope :all, default: true

  #Sidebar
  filter :name
  filter :affiliate, input_html: {class: 'chosen-select-sidebar'}
  filter :starts_at
  filter :expires_at

  #Index page
  index do
    column :name
    column :affiliate
    column :starts_at
    column :expires_at
    column :disabled, sortable: :disabled  do |studio|
      studio.disabled? ? 'Disabled' : 'Active'
    end
    actions
  end

  form do |f|
    f.inputs 'Studio' do
      f.input :name
      f.input :display_name
      # f.input :welcome_message
      f.input :getting_started_markdown, label: "Getting Started Dialog", hint: "You can use markdown to style this text"
      f.input :starts_at, :as => :just_datetime_picker
      f.input :expires_at, :as => :just_datetime_picker
      f.input :icon, as: :file, hint: f.template.image_tag(f.object.icon_url.to_s)
      f.input :image, as: :file, hint: f.template.image_tag(f.object.image_url.to_s)
      f.input :disabled
    end

    f.inputs 'Sticker Packs' do
      f.input :sticker_packs,
              as: :check_boxes,
              collection: StickerPack.all,
              input_html: {class: 'chosen-select', id: 'studio_config_sticker_packs'}
    end

    f.inputs 'Starting Information' do
      f.input :scene, collection: Scene.where('name is not null and deleted != true'), input_html: {class: 'chosen-select'}
    end

    f.inputs 'Contests' do
      f.input :contest, collection: GalleryTemplate.all(), input_html: {class: 'chosen-select'}
    end
    f.actions
  end

  show do |sc|
    attributes_table do
      rows :name, :display_name
      rows :affiliate, :starts_at, :expires_at
      row :icon do
        image_tag(sc.icon_url.to_s)
      end
      row :image do
        image_tag(sc.image_url.to_s)
      end
      row "Getting Started Dialog" do
        sc.getting_started_html.to_s.html_safe
      end
      row :disabled do
        sc.disabled? ? 'Disabled' : 'Active'
      end
      row :sort_order
    end

    render partial: 'show', locals: {sc: sc}
  end

  controller do
    # Never trust parameters from the scary internet, only allow the white list through.
    def permitted_params
      params.permit!
    end

    def new
      if params[:id]
        begin
          sc = Studio.find(params[:id])
          @studio = Studio.new(sc.attributes.except(:id))
          @studio.studio_sticker_packs = sc.studio_sticker_packs
          @studio.name += '(copy)'
        rescue
          @studio = Studio.new
        end
      else
        @studio = Studio.new
      end
    end

    def update (options={}, &block)
      studio = Studio.find(params[:id])
      # If one or more sticker packs have been removed from the studio, touch the studio so the mobile app will know it needs to update
      touched = false
      old_sticker_pack_ids = []
      studio.sticker_packs.each do |sticker_pack|
        unless params[:studio][:sticker_pack_ids].include?(sticker_pack.id.to_s)
          studio.touch
          studio.save
          touched = true
          break
          old_sticker_pack_ids << sticker_pack.id.to_s
        end
      end
      # If one or more sticker packs have been added to the studio, touch the studio so the mobile app will know it needs to update
      if !touched
        params[:studio][:sticker_pack_ids].each do |new_sticker_pack_id|
          unless old_sticker_pack_ids.include?(new_sticker_pack_id)
            studio.touch
            studio.save
            break
          end
        end
      end
      super
    end

  end

  member_action :order_sticker_packs, method: :post do
    begin
      studio = Studio.find(params[:id])
      params[:sticker_pack_ids].each_with_index do |id, idx|
        studio.studio_sticker_packs.where(sticker_pack_id: id).first.update_attribute(:sort_order, idx)
      end

      render js: "$('#sticker_packs_response').addClass('success').removeClass('error').html('Sticker Pack order saved');"
    rescue
      render js: "$('#sticker_packs_response').removeClass('success').addClass('error').html('Couldn't find Studio, please refresh page and try again.);"
    end
  end

  action_item :only => :index do
    link_to('Import Excel', import_admin_studios_path)
  end

  NUM_NON_META_COLUMNS ||= 4

  collection_action :import, :method => [:get, :post] do
    if params[:file]
      name =  params[:file].original_filename
      tmp_dir = "/tmp"
      # create the file path
      zip_file_path = File.join(tmp_dir, name)
      # write the file
      File.open(zip_file_path, "wb") { |f| f.write(params[:file].read) }

      require 'zip/filesystem'
      require 'creek'
      Zip::File.open(zip_file_path) do |zipfile|
        excel_file = zipfile.glob('*.xlsx').first || zipfile.glob('*.xls').first
        excel_file_path = File.join(tmp_dir, excel_file.name)
        File.open(excel_file_path, "wb") { |f| f.write(excel_file.get_input_stream.read) }

        studio_name = excel_file.name.split('.')[0]
        existing_studios = Studio.where("name = '#{studio_name}'")
        existing_studio = false
        if existing_studios.any?
          studio = existing_studios.take
          existing_studio = true
        else
          studio = Studio.new({:name => studio_name, :display_name => studio_name})
        end
        doc = Creek::Book.new(excel_file_path)
        doc.sheets.each do |sheet|
          sticker_pack = nil
          if existing_studio
            studio.sticker_packs.each do |sp|
              if sp.display_name == sheet.name
                sticker_pack = sp
              end
            end
          end
          if sticker_pack.nil?
            sticker_pack = StickerPack.new({:display_name => sheet.name})
          end
          first = true
          meta_properties = []
          row_num = 0
          sheet.rows.each do |row|
            if first
              for i in NUM_NON_META_COLUMNS..(row.values.size - 1)
                meta_properties << row.values[i]
              end
            else
              row_num += 1
              sticker = nil
              if existing_studio
                sticker_pack.stickers.each do |s|
                  if s.display_name == row.values[0]
                    sticker = s
                  end
                end
              end
              if sticker.nil?
                if row.values[2] == 'Background'
                  sticker = Background.new
                else
                  sticker = Sticker.new
                end
              end
              sticker.type = (row.values[2] == 'Background' ? 'Background' : 'Sticker')
              if !row.values[0].nil?
                sticker.display_name = row.values[0]

                image_file = File.join tmp_dir, row.values[1]
                File.open(image_file, "wb") {|f| f.write(zipfile.glob(row.values[1]).first.get_input_stream.read)}
                File.open(image_file, "r") do |file|
                  sticker.image = file
                  sticker.mirrorable = row.values[3]
                  sticker.priority = row_num
                  sticker.save!
                end
                File.delete image_file

                if !sticker_pack.stickers.include?(sticker)
                  sticker_pack.stickers << sticker
                end
                for i in NUM_NON_META_COLUMNS..(row.values.size - 1)
                  item_property = nil
                  if row.values[i]
                    if existing_studio
                      sticker.item_properties.each do |ip|
                        if ip.key == meta_properties[i-NUM_NON_META_COLUMNS]
                          item_property = ip
                          item_property.value = row.values[i]
                        end
                      end
                    end
                    if item_property.nil?
                      item_property = ItemProperty.new(key: meta_properties[i-NUM_NON_META_COLUMNS], value: row.values[i], item: sticker)
                    end
                    item_property.save!
                  end
                end
              end
            end
            first = false
          end

          sticker_pack.save!
          if !studio.sticker_packs.include?(sticker_pack)
            studio.sticker_packs << sticker_pack
          end
        end

        studio.save!
        File.delete excel_file_path
      end

      File.delete zip_file_path
    end
  end


end
