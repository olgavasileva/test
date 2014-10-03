ActiveAdmin.register CannedQuestionImage do
  menu parent: 'Canned Images', label: 'Question Images'
  permit_params :image, :position, :remove_image

  config.sort_order = 'position_asc' # assumes you are using 'position' for your acts_as_list column
  sortable # creates the controller action which handles the sorting

  index do
    sortable_handle_column
    id_column
    column :id
    column :image do |i|
      image_tag i.web_image_url, height: 80
    end
    actions
  end


  form do |f|
    f.inputs "Background Image", multipart: true do
      if f.object.image.present?
        f.input :remove_image, as: :boolean
      end
      f.input :image, as: :file, image_preview: true
    end
    f.actions
  end
end
