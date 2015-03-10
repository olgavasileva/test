ActiveAdmin.register Question do
  menu parent: 'Questions'

  permit_params :id, :position, :category_id, :title, :state, :special, :trending_multiplier, :disable_question_controls, :created_at

  controller do
    def scoped_collection
      end_of_association_chain.includes(:trend)
    end
  end

  filter :user
  filter :title
  filter :id
  filter :uuid
  filter :type
  filter :category
  filter :state, as: :check_boxes, collection: Question::STATES
  filter :kind, as: :check_boxes, collection: Question::KINDS
  filter :allow_multiple_answers_from_user

  member_action :apply_created_at_to_feed_items do
    q = Question.find params[:id]
    q.feed_items.update_all published_at: q.created_at
    flash[:notice] = "Updated feed #{q.feed_items.count} items"
    redirect_to action: :index
  end

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
    column "TI", sortable: 'trends.rate' do |q|
      q.trend_rate
    end
    column "T*", sortable: :trending_multiplier do |q|
      q.trending_multiplier
    end
    column :created_at
    column do |q|
      link_to "Update All Published At Dates", apply_created_at_to_feed_items_admin_question_path(q)
    end
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
      f.input :trending_multiplier
      f.input :disable_question_controls
      f.input :allow_multiple_answers_from_user
      f.input :created_at
    end
    f.actions
  end

end
