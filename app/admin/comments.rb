ActiveAdmin.register Comment do
  controller do
    def scoped_collection
      Comment.includes(:likes)
    end
  end

  filter :user
  filter :body
  filter :created_at

  index do
    selectable_column
    id_column
    column :comment_type
    column :body
    column "Likes" do |comment|
      comment.likes.size
    end
    column :created_at
    actions
  end
end
