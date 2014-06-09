class CreatePacks < ActiveRecord::Migration
  def change
    create_table :packs do |t|
      t.string :title
      t.integer :user_id

      t.timestamps
    end
    add_index :packs, :user_id
  end
end
