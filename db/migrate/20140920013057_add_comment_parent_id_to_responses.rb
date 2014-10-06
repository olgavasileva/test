class AddCommentParentIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :comment_parent_id, :integer
  end
end
