class AddMostResponsesSurveyCount < ActiveRecord::Migration
  def change
    add_column :ad_units, :related_surveys_count, :integer, default: 3, null: false
  end
end
