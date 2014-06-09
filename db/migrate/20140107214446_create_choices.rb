class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :label
      t.string :image_url
      t.string :description
      t.integer :question_id

      t.timestamps
    end

    add_index :choices, :question_id
  end
end
