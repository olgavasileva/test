class AddTrendIdToQuestion < ActiveRecord::Migration
  def up
    add_column :questions, :trend_id, :integer
    add_index :questions, :trend_id
    remove_column :questions, :trending_index

    begin
      Question.all.find_each do |q|
        q.create_trend
        q.save
      end
    rescue
    end
  end

  def down
    remove_column :questions, :trend_id
    add_column :questions, :trending_index, :integer, default: 0
    add_index :questions, :trending_index
  end
end
