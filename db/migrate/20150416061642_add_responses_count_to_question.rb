class AddResponsesCountToQuestion < ActiveRecord::Migration
  def up
    add_column :questions, :responses_count, :integer, default: 0
    add_index :questions, :responses_count

    begin
      Question.all.find_each do |q|
        Question.reset_counters(q.id, :responses)
      end
    rescue
    end
  end

  def down
    remove_column :questions, :responses_count
  end
end
