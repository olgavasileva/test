class CreateUserQuestions < ActiveRecord::Migration
  def change
    create_table :feed_items_v2 do |t|
      t.references :user, index: true
      t.references :question, index: true
      t.datetime :published_at, index: true
      t.datetime :hidden_at
      t.boolean :hidden, index: true
      t.string :hidden_reason, index: true

      t.timestamps
    end

    add_index :feed_items_v2, [:hidden, :hidden_reason], name: "idx1"
    add_index :feed_items_v2, [:hidden, :hidden_reason, :question_id], name: 'idx2'
    add_index :feed_items_v2, [:user_id, :hidden, :published_at], name: 'idx3'
    add_index :feed_items_v2, [:user_id, :hidden, :hidden_reason], name: 'idx4'
    add_index :feed_items_v2, [:user_id, :hidden, :hidden_reason, :question_id], name: 'idx5'
  end
end
