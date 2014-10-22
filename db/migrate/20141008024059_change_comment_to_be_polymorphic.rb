class ChangeCommentToBePolymorphic < ActiveRecord::Migration
  def up
    add_column :comments, :commentable_id, :integer
    add_column :comments, :commentable_type, :string

    begin
      Comment.reset_column_information
      Comment.all.each do |c|
        if c.parent_id
          c.commentable_id = c.parent_id
          c.commentable_type = "Comment"
        elsif c.question_id
          c.commentable_id = c.question_id
          c.commentable_type = "Question"
        elsif c.response_id
          c.commentable_id = c.response_id
          c.commentable_type = "Response"
        end

        c.save validate:false
      end
    rescue
      # in case Comment isn't around some day
    end

    remove_column :comments, :question_id
    remove_column :comments, :response_id
    remove_column :comments, :parent_id
  end

  def down
    add_column :comments, :question_id, :integer
    add_column :comments, :response_id, :integer
    add_column :comments, :parent_id, :integer

    begin
      Comment.reset_column_information
      Comment.all.each do |c|
        if c.commentable_type == "Comment"
          c.parent_id = c.commentable_id
        elsif c.commentable_type == "Question"
           c.question_id = c.commentable_id
        elsif c.commentable_type == "Response"
          c.response_id = c.commentable_id
        end

        c.save validate:false
      end
    rescue
      # in case Comment isn't around some day
    end

    remove_column :comments, :commentable_id, :integer
    remove_column :comments, :commentable_type, :string
  end
end
