ActiveAdmin.register MultipleChoiceQuestion  do
  menu parent: 'Questions'

  permit_params :id, :position, :category_id, :title, :state, :special, :disable_question_controls

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
    column :min_responses
    column :max_responses
    column "Choices" do |q|
      link_to pluralize(q.choices.count, "choice"), admin_multiple_choice_question_multiple_choices_path(q)
    end
    column :created_at
    actions
  end

  form do |f|
    f.inputs f.object.type do
      f.input :state, collection: Question::STATES, include_blank: false
      f.input :category
      f.input :title
      f.input :require_comment
      f.input :min_responses
      f.input :max_responses
      f.input :disable_question_controls
    end
    f.actions
  end

end