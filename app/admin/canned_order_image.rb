ActiveAdmin.register CannedOrderChoiceImage do
  menu parent: 'Canned Images', label: "Order Choice Images"
  permit_params :image, :remove_image

  index do
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
