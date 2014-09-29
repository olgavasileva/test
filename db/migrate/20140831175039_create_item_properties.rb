class CreateItemProperties < ActiveRecord::Migration
  def change
    create_table :item_properties do |t|
      t.string :key
      t.string :value
      t.references :item, polymorphic: true, index: true

      t.timestamps
    end
  end
end
