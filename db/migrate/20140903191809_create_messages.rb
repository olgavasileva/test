class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.string :type
      t.datetime :read_at
      t.integer :other_user_id
      t.integer :question_id
      t.integer :response_id
      t.references :user, index: true

      t.timestamps
    end
  end
end
