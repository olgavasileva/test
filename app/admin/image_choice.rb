ActiveAdmin.register ImageChoice  do
  belongs_to :image_choice_question

  config.filters = false
  batch_action :destroy, false

  actions :index, :edit, :update, :show
  action_item do
    link_to('All Questions', admin_questions_path)
  end

  permit_params :id, :title, :position, :rotate, :background_image_id, background_image_attributes: [:id, :image]

  index do
    column :id
    column :question
    column :title
    column :background_image do |q|
      image_tag q.background_image.image.url, style:"max-height: 100px"
    end
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
      row :rotate
      row :position
      row :created_at
      row :updated_at
    end
  end
end