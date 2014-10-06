class ChangeCommentTypeInResponses < ActiveRecord::Migration
  def change
    remove_column :responses, :comment, :text
    remove_reference :responses, :comment_parent, index: true

    add_reference :responses, :comment, index: true
    add_reference :comments, :response, index: true
  end
end
