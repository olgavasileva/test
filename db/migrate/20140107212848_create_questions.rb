class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.string :info
      t.string :image_url
      t.integer :question_type
      t.integer :user_id

      t.timestamps
    end

    add_index :questions, :user_id
  end
end
