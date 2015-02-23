class CreateDataProviders < ActiveRecord::Migration
  def change
    create_table :data_providers do |t|
      t.string :name
      t.integer :priority

      t.timestamps
    end
  end
end
