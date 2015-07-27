class CreateListicals < ActiveRecord::Migration
  def change
    create_table :listicals do |t|
      t.string :title
      t.text :header
      t.integer :user_id
      t.text :footer
    end
  end
end
