ActiveAdmin.register Question do
  permit_params :id, :position, :category_id, :title

  index do
    column :id
    column :type
    column :category
    column :title
    column :kind
    column :position
    actions
  end

  form do |f|
    f.inputs f.object.type do
      f.input :position
      f.input :category
      f.input :title
    end
    f.actions
  end

end
