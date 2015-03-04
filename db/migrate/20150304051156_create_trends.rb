class CreateTrends < ActiveRecord::Migration
  def change
    create_table :trends do |t|
      t.integer :new_event_count
      t.datetime :calculated_at
      t.decimal :filter_event_count, precision: 10, scale: 2
      t.decimal :filter_minutes, precision: 10, scale: 2
      t.decimal :rate, precision: 10, scale: 2

      t.timestamps
    end
  end
end
