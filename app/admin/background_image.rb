ActiveAdmin.register BackgroundImage do
  permit_params :image, :position, :remove_image

  config.sort_order = 'position_asc' # assumes you are using 'position' for your acts_as_list column
  sortable # creates the controller action which handles the sorting

  index do
    sortable_handle_column
    column :id
    column :image do |i|
      image_tag i.image.url, height: 320
    end
  end


  form do |f|
    f.inputs "Background Image", multipart: true do
      f.input :remove_image, as: :boolean
      f.input :image, as: :file, image_preview: true
    end
    f.actions
  end
end
