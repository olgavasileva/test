ActiveAdmin.register Comment do
  filter :user
  filter :body
  filter :created_at

  index do
    selectable_column
    id_column
    column :comment_type
    column :body
    column "Likes" do |comment|
      comment.likes.count
    end
    column :created_at
    actions
  end
end