class CreateAdUnits < ActiveRecord::Migration
  def change
    create_table :ad_units do |t|
      t.string :name
      t.text :default_meta_data
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
