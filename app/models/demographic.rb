class Demographic < ActiveRecord::Base
  belongs_to :response

  GENDERS ||= %w(male female)
  AGE_RANGES ||= %w(<18 18-24 25-34 35-44 45-54 55-64 65+)
  HOUSEHOLD_INCOMES ||= %w(0-50k 50k-100k 100k-150k 150k+)
  CHILDRENS ||= %w(false true)
  ETHNICITYS ||= %w(caucasian african_american asian hispanic other)
  EDUCATION_LEVELS ||= %w(no_college college grad_school)
  POLITICAL_AFFILIATIONS ||= %w(republican democrat independent)
  POLITICAL_ENGAGEMENTS ||= %w(active somewhat_active inactive)

  validates :gender, inclusion: {in: GENDERS, allow_nil: true}
  validates :age_range, inclusion: {in: AGE_RANGES, allow_nil: true}
  validates :household_income, inclusion: {in: HOUSEHOLD_INCOMES, allow_nil: true}
  validates :children, inclusion: {in: CHILDRENS, allow_nil: true}
  validates :ethnicity, inclusion: {in: ETHNICITYS, allow_nil: true}
  validates :education_level, inclusion: {in: EDUCATION_LEVELS, allow_nil: true}
  validates :political_affiliation, inclusion: {in: POLITICAL_AFFILIATIONS, allow_nil: true}
  validates :political_engagement, inclusion: {in: POLITICAL_ENGAGEMENTS, allow_nil: true}
end
