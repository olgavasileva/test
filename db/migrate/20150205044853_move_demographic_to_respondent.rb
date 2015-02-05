class MoveDemographicToRespondent < ActiveRecord::Migration
  def up
    add_column :demographics, :respondent_id, :integer, index: true
    remove_column :demographics, :response_id
  end

  def down
    add_column :demographics, :response_id, :integer, index: true
    remove_column :demographics, :respondent_id
  end
end
