ActiveAdmin.register MultipleChoice  do
  belongs_to :multiple_choice_question

  permit_params :id, :title, :position, :rotate, :muex, :background_image_id, background_image_attributes: [:image]

  index do
    selectable_column
    column :id
    column :question
    column :title
    column :background_image do |q|
      image_tag q.background_image.image.url, style:"max-height: 100px"
    end
    column :muex
    column :rotate
    column :position
    column :created_at
    actions
  end

  form partial: "form"

  show do |c|
    attributes_table do
      row :id
      row :question
      row :title
      row :background_image do |choice|
        image_tag choice.background_image.image.url, style:"max-height: 100px"
      end
      row :muex
      row :rotate
      row :position
      row :created_at
      row :updated_at
    end
  end
end