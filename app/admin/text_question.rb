ActiveAdmin.register TextQuestion  do
  menu parent: 'Questions'

  permit_params :id, :position, :category_id, :title, :state, :special, :require_comment, :text_type, :min_characters, :max_characters, :background_image_id, background_image_attributes: [:image]

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
    column :text_type
    column :min_characters
    column :max_characters
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
      row :position
      row :state
      row :kind
      row :text_type
      row :min_characters
      row :max_characters
      row :created_at
      row :udpated_at
    end
  end

end