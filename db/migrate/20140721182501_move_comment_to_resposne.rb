class MoveCommentToResposne < ActiveRecord::Migration
  def up
    drop_table :comments
    add_column :responses, :comment, :string
  end

  def down
    create_table "comments", force: true do |t|
      t.string   "content"
      t.integer  "user_id"
      t.integer  "question_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["question_id"], name: "index_comments_on_question_id", using: :btree
    add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

    remove_column :responses, :comment
  end
end
