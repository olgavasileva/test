class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.references :survey, index: true
      t.references :key_question, index: true

      t.timestamps
    end
  end
end
