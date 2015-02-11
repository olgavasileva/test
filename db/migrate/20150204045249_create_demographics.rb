class CreateDemographics < ActiveRecord::Migration
  def change
    create_table :demographics do |t|
      t.references :response, index: true
      t.string :gender, index: true
      t.string :age_range, index: true
      t.string :household_income, index: true
      t.string :children, index: true
      t.string :ethnicity, index: true
      t.string :education_level, index: true
      t.string :political_affiliation, index: true
      t.string :political_engagement, index: true

      t.timestamps
    end
  end
end
