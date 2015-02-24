class DemographicBase < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :respondent

  GENDERS ||= %w(male female)
  AGE_RANGES ||= %w(<18 18-24 25-34 35-44 45-54 55+)
  HOUSEHOLD_INCOMES ||= %w(0-100k 100k+)
  CHILDRENS ||= %w(false true)
  ETHNICITYS ||= %w(caucasian african_american asian hispanic)
  EDUCATION_LEVELS ||= %w(no_college college)
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

  delegate :username, to: :respondent, allow_nil: true

  def age= age
    self.age_range = case true
    when age.nil?
      nil
    when age < 18
      '<18'
    when age < 25
      '18-24'
    when age < 35
      '25-34'
    when age < 45
      '35-44'
    when age < 55
      '45-54'
    else
      '55+'
    end
  end

  #
  # Data based on ip_address
  #

  def latitude
    geo && geo.location.latitude
  end

  def longitude
    geo && geo.location.longitude
  end

  def metro_code
    geo && geo.location.metro_code
  end

  def city
    geo && geo.city.name
  end

  def state
    geo && geo.subdivisions.first.iso_code if geo.subdivisions.present?
  end

  def postal_code
    geo && geo.postal.code
  end

  def country
    geo && geo.country.iso_code
  end


  private

    def geo
      @geo ||= MaxMind.city_db.lookup ip_address if ip_address
    end

end