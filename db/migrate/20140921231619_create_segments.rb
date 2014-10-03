class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.references :user, index: true
      t.string :name
      t.integer :potential_reach_count
      t.datetime :potential_reach_computed_at

      t.timestamps
    end
  end
end
