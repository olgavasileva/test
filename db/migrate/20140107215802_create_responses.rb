class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :order
      t.float :percent
      t.integer :star
      t.integer :choice_id
      t.integer :answer_id

      t.timestamps
    end

    add_index :responses, :choice_id
    add_index :responses, :answer_id
  end
end
