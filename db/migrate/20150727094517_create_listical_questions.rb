class CreateListicalQuestions < ActiveRecord::Migration
  def change
    create_table :listical_questions do |t|
      t.string :title
      t.text :body
      t.integer :listical_id
    end
  end
end
