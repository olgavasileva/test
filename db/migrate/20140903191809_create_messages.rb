class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :type
      t.datetime :read_at
      t.datetime :completed_at
      t.integer :response_count
      t.integer :comment_count
      t.integer :share_count
      t.integer :question_id
      t.references :user, index: true

      t.timestamps
    end
  end
end
