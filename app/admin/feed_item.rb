ActiveAdmin.register FeedItem do
  belongs_to :user
  config.sort_order = "created_at_desc"

  index do
    column :id
    column "Question" do |fi|
      link_to fi.question.title, fi.question
    end
    column :created_at

    actions
  end

end