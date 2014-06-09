class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.integer :user_id
      t.integer :question_id

      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, :question_id
  end
end
