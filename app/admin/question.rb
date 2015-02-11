ActiveAdmin.register Question do
  menu parent: 'Questions'

  permit_params :id, :position, :category_id, :title, :state, :special, :trending_index, :trending_multiplier, :disable_question_controls

  filter :user
  filter :title
  filter :id
  filter :uuid
  filter :type
  filter :category
  filter :state, as: :check_boxes, collection: Question::STATES
  filter :kind, as: :check_boxes, collection: Question::KINDS
  filter :allow_multiple_answers_from_user

  index do
    selectable_column
    column :id
    column :title
    column :type
    column :category
    column :user
    column "Resp" do |q|
      q.responses.count
    end
    column "Cmts" do |q|
      q.comments.count
    end
    column :state
    column :kind
    column :special
    column :require_comment
    column "TI" do |q|
      q.trending_index
    end
    column "T*" do |q|
      q.trending_multiplier
    end
    column :created_at
    column "In Feeds" do |q|
      q.feed_items.count
    end
    actions
  end

  form do |f|
    f.inputs f.object.type do
      f.input :state, collection: Question::STATES, include_blank: false
      f.input :category
      f.input :title
      f.input :special
      f.input :require_comment
      f.input :trending_index
      f.input :trending_multiplier
      f.input :disable_question_controls
      f.input :allow_multiple_answers_from_user
    end
    f.actions
  end

end
