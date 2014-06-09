class CreateSharings < ActiveRecord::Migration
  def change
    create_table :sharings do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :question_id

      t.timestamps
    end

    add_index :sharings, :sender_id
    add_index :sharings, :receiver_id
    add_index :sharings, :question_id
    add_index :sharings, [:sender_id, :receiver_id, :question_id], unique: true
  end
end
