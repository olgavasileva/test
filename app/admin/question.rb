ActiveAdmin.register Question do
  permit_params :id, :position, :category_id, :title, :state

  filter :user
  filter :title
  filter :type
  filter :category
  filter :state, as: :check_boxes, collection: Question::STATES
  filter :kind, as: :check_boxes, collection: Question::KINDS

  index do
    selectable_column
    column :id
    column :type
    column :category
    column :title
    column :state
    column :kind
    column :special
    column :require_comment
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
    end
    f.actions
  end

end
