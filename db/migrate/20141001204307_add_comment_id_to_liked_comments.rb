class AddCommentIdToLikedComments < ActiveRecord::Migration
  def change
    add_reference :liked_comments, :comment, index: true
  end
end
