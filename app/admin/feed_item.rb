ActiveAdmin.register FeedItem do
  belongs_to :user
  config.sort_order = "created_at_desc"

  index do
    column :id
    column "Question ID" do |fi|
      link_to fi.question.id, admin_question_path(fi.question)
    end
    column "Question" do |fi|
      link_to fi.question.title, admin_question_path(fi.question)
    end
    column :created_at

    actions
  end

end