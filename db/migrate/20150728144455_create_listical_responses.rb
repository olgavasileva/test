class CreateListicalResponses < ActiveRecord::Migration
  def change
    create_table :listical_responses do |t|
      t.integer :user_id, null: false
      t.integer :question_id, null: false
      t.boolean :is_up, null: false, default: false
      t.timestamps
    end
  end
end
