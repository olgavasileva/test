class RenameResponsesCount < ActiveRecord::Migration
  def change
    rename_column :questions, :responses_count, :recent_responses_count
  end
end
