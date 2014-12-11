ActiveAdmin.register FeedItem do
  belongs_to :user
  config.sort_order = "published_at_desc"

  permit_params :published_at, :hidden, :hidden_reason, :hidden_at

  index do
    column :id
    column "Question ID" do |fi|
      link_to fi.question.id, admin_question_path(fi.question)
    end
    column "Question" do |fi|
      link_to fi.question.title, admin_question_path(fi.question)
    end
    column :published_at

    actions
  end

  form do |f|
    f.inputs do
      f.input :published_at
      f.input :hidden
      f.input :hidden_reason, collection: FeedItem::HIDDEN_REASONS
      f.input :hidden_at
    end
    f.actions
  end

end