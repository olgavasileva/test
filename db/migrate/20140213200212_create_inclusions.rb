class CreateInclusions < ActiveRecord::Migration
  def change
    create_table :inclusions do |t|
      t.integer :pack_id
      t.integer :question_id

      t.timestamps
    end
    add_index :inclusions, :pack_id
    add_index :inclusions, :question_id
    add_index :inclusions, [:pack_id, :question_id], unique: true
  end
end
