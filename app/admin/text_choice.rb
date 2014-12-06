ActiveAdmin.register TextChoice  do
  belongs_to :text_choice_question

  permit_params :id, :title, :position, :rotate, :muex, :background_image_id, background_image_attributes: [:image]

  index do
    selectable_column
    column :id
    column :question
    column :title
    column :rotate
    column :position
    column :created_at
    actions
  end

  show do |c|
    attributes_table do
      row :id
      row :question
      row :title
      row :rotate
      row :position
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title, as: :string
      f.input :position
      f.input :rotate
      f.input :muex
    end
    f.actions
  end
end