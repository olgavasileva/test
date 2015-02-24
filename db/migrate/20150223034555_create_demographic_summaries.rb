class CreateDemographicSummaries < ActiveRecord::Migration
  def change
    create_table :demographic_summaries do |t|
      t.string :gender
      t.string :age_range
      t.string :household_income
      t.string :children
      t.string :ethnicity
      t.string :education_level
      t.string :political_affiliation
      t.string :political_engagement
      t.references :respondent, index: true

      t.timestamps
    end
  end
end
