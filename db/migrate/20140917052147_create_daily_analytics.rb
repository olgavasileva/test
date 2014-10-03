class CreateDailyAnalytics < ActiveRecord::Migration
  def change
    create_table :daily_analytics do |t|
      t.integer :user_id
      t.string :metric
      t.integer :total
      t.date :date

      t.timestamps
    end

    add_index :daily_analytics, [:user_id, :metric, :date]
  end
end
