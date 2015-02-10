class Demographic < ActiveRecord::Base
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

  def update_from_provider_data! provider, version, raw_data
    self.data_provider = provider
    self.data_version = version
    self.raw_data = raw_data

    injest_raw_data!
  end

  def injest_raw_data!
    calculate_gender
    calculate_age_range
    calculate_household_income
    calculate_children
    calculate_ethnicity
    calculate_education_level
    calculate_political_affiliation
    calculate_political_engagement

    save!
  end

  def self.aggregate_for_question question
  end

  def self.aggregate_for_choice choice
  end

  # private
    # "qcseg=D;qcseg=T;qcseg=50082;qcseg=50079;qcseg=50076;qcseg=50075;qcseg=50074;qcseg=50073;qcseg=50062;qcseg=50060;qcseg=50059;qcseg=50057;qcseg=50054;"
    def data_values
      @data_values ||= raw_data.split(";").map{|pair| pair.split("=").last}
    end

    def raw_data_contains_some_info?
      calculate_gender
      calculate_household_income

      gender.present? || household_income.present?
    end

    def calculate_gender
      self.gender ||= begin
        male_matches = data_values & m('MALE', "MALE_21-34", "MALE_25-54", "MALE_35-54", "MALE_21+", "MALE_55+", "MALE_18-24", "MALE_18-34", "MALE_18-49")
        female_matches = data_values & m("FEMALE", "FEMALE_21-34", "FEMALE_18-24", "FEMALE_18-34", "FEMALE_18-49", "FEMALE_21+", "FEMALE_25-54", "FEMALE_35-54", "FEMALE_55+")

        if male_matches.count > 0 || female_matches.count > 0
          male_matches.count > female_matches.count ? 'male' : 'female'
        end
      end
    end

    def calculate_household_income
      self.household_income ||= begin
        if data_values & m('100K-')
          '0-100k'
        elsif data_values & m('100K+')
          '100k+'
        end
      end
    end

    def calculate_children
      self.children ||= begin
        if data_values & m('MOMS', 'PARENTS')
          "true"
        elsif raw_data_contains_some_info?   # if other data is present, assume lack of this info is that they don't have children
          "false"
        end
      end
    end

    def calculate_ethnicity
      self.ethnicity ||= begin
        if data_values & m('ASIAN')
          'asian'
        elsif data_values & m('AFRICAN_AMERICAN')
          'african_american'
        elsif data_values & m('HISPANIC')
          'hispanic'
        elsif raw_data_contains_some_info?   # if other data is present, assume lack of this info is that they're caucasian
          'caucasian'
        end
      end
    end

    def calculate_education_level
      self.education_level ||= begin
        if data_values & m('COLLEGE+')
          'college'
        elsif raw_data_contains_some_info?
          'no_college'
        end
      end
    end

    def calculate_political_affiliation
      # No mappings for this at this time (2/10/2015)
      self.political_affiliation = nil
    end

    def calculate_political_engagement
      # No mappings for this at this time (2/10/2015)
      self.political_engagement = nil
    end


    def calculate_age_range
      self.age_range ||= begin
        ai = age_intervals
        eai = encompassing_age_interval ai
        while ai.count > 0 && eai.nil?
          ai.shift!
          eai = encompassing_age_interval ai
        end

        if eai.present?
          tree = IntervalTree::Tree.new [(0...18), (18...25), (25...35), (35...45), (45...55), (55...105)]
          case tree.search eai
          when m(0...18) then "<18"
          when m(18...25) then "18-24"
          when (25...35) then "25-34"
          when (35...45) then "35-44"
          when (45...55) then "45-54"
          when (55...105) then "55+"
          end
        end
      end
    end

    def encompassing_age_interval intervals
      if intervals.present?
        min = intervals.map{|i| i.min}.min
        max = intervals.map{|i| i.max}.max
        if min <= max
          (min...max)
        end
      end
    end

    def age_intervals
      keys = data_values & m("18-24", "18-34", "18-49", "21+", "25-54", "35-54", "55+", "21-34", "MALE_21-34", "MALE_25-54", "MALE_35-54", "MALE_21+", "MALE_55+", "MALE_18-24", "MALE_18-34", "MALE_18-49", "FEMALE_21-34", "FEMALE_18-24", "FEMALE_18-34", "FEMALE_18-49", "FEMALE_21+", "FEMALE_25-54", "FEMALE_35-54", "FEMALE_55+")
      keys.map do |k|
        case [k]
        when m("18-24") then (18...25)
        when m("18-34") then (18...35)
        when m("18-49") then (18...50)
        when m("21+") then (21..105)
        when m("25-54") then (25...55)
        when m("35-54") then (35...55)
        when m("55+") then (55...105)
        when m("21-34") then (21...35)
        when m("MALE_21-34") then (21...35)
        when m("MALE_25-54") then (25...55)
        when m("MALE_35-54") then (35...55)
        when m("MALE_21+") then (21...105)
        when m("MALE_55+") then (55...105)
        when m("MALE_18-24") then (18...25)
        when m("MALE_18-34") then (18...35)
        when m("MALE_18-49") then (18...50)
        when m("FEMALE_21-34") then (21...35)
        when m("FEMALE_18-24") then (18...25)
        when m("FEMALE_18-34") then (18...35)
        when m("FEMALE_18-49") then (18...50)
        when m("FEMALE_21+") then (21...105)
        when m("FEMALE_25-54") then (25...55)
        when m("FEMALE_35-54") then (35...55)
        when m("FEMALE_55+") then (55...105)
        end
      end
    end

    def m *keys
      keys.map{|key| mapping[key]}
    end

    def mapping
      @mapping ||= {
        "18-24" => "50055",
        "18-34" => "50056",
        "18-49" => "50057",
        "21+" => "50058",
        "25-54" => "50059",
        "35-54" => "50060",
        "55+" => "50061",
        "21-34" => "50086",
        "MALE_21-34" => "50084",
        "MALE_25-54" => "50075",
        "MALE_35-54" => "50076",
        "MALE_21+" => "50074",
        "MALE_55+" => "50077",
        "MALE_18-24" => "50071",
        "MALE_18-34" => "50072",
        "MALE_18-49" => "50073",
        "FEMALE_21-34" => "50085",
        "FEMALE_18-24" => "50063",
        "FEMALE_18-34" => "50064",
        "FEMALE_18-49" => "50065",
        "FEMALE_21+" => "50066",
        "FEMALE_25-54" => "50067",
        "FEMALE_35-54" => "50068",
        "FEMALE_55+" => "50069",
      }
    end
end
