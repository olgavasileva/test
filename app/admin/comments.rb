ActiveAdmin.register Comment do
  filter :user
  filter :body
  filter :created_at

  index do
    selectable_column
    id_column
    column "Commented On" do |comment|
      if comment.commentable.kind_of? Question
        "<em>Question:</em> #{ERB::Util.h comment.commentable.title}".html_safe
      elsif comment.commentable.kind_of? Comment
        "<em>Comment:</em> #{link_to ERB::Util.h(comment.commentable.body), [:admin, comment.commentable]}".html_safe
      elsif comment.commentable.kind_of? Response
        "<em>Response to:</em> #{ERB::Util.h comment.commentable.question.title} <br/> <strong><em>#{ERB::Util.h comment.commentable.description}</em></strong>".html_safe
      end
    end
    column :body
    column "Likes" do |comment|
      comment.likes.count
    end
    column :created_at
    actions
  end
end