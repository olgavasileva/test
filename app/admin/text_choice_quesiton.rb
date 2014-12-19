ActiveAdmin.register TextChoiceQuestion  do
  menu parent: 'Questions'

  permit_params :id, :position, :category_id, :title, :state, :special, :require_comment, :background_image_id, :disable_question_controls, background_image_attributes: [:image]

  filter :user
  filter :title
  filter :id
  filter :uuid
  filter :type
  filter :category
  filter :state, as: :check_boxes, collection: Question::STATES
  filter :kind, as: :check_boxes, collection: Question::KINDS

  index do
    selectable_column
    column :id
    column :title
    column :category
    column :user
    column "Responses" do |q|
      q.responses.count
    end
    column "Comments" do |q|
      q.comments.count
    end
    column :state
    column :kind
    column :require_comment
    column "Choices" do |q|
      link_to pluralize(q.choices.count, "choice"), admin_text_choice_question_text_choices_path(q)
    end
    column :created_at
    actions
  end

  form partial: "form"

  show do
    attributes_table do
      row :id
      row :user
      row :title
      row :background_image do |q|
        image_tag q.background_image.image.url, style:"max-height: 100px"
      end
      row :rotate
      row :position
      row :created_at
      row :udpated_at
      row :state
      row :kind
    end
  end

end