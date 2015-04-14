ActiveAdmin.register YesNoChoice  do
  belongs_to :yes_no_question

  config.filters = false
  batch_action :destroy, false

  actions :index, :edit, :update, :show
  action_item do
    link_to('All Questions', admin_questions_path)
  end

  permit_params :id, :title, :position, :rotate, :muex, :background_image_id, background_image_attributes: [:image]

  index do
    column :id
    column :question
    column :title
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
      row :rotate
      row :position
      row :created_at
      row :updated_at
    end
  end
end