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

  delegate :username, to: :respondent, allow_nil: true

  def update_from_provider_data! provider, version, raw_data
    @data_values = nil
    self.data_provider = provider
    self.data_version = version
    self.raw_data = raw_data

    injest_raw_data!
  end

  def injest_raw_data!
    self.gender = calculated_gender
    self.age_range = calculated_age_range
    self.household_income = calculated_household_income
    self.children = calculated_children
    self.ethnicity = calculated_ethnicity
    self.education_level = calculated_education_level
    self.political_affiliation = calculated_political_affiliation
    self.political_engagement = calculated_political_engagement

    save!
  end

  def self.aggregate_for_question question
  end

  def self.aggregate_for_choice choice
  end

  # private
    # "qcseg=D;qcseg=T;qcseg=50082;qcseg=50079;qcseg=50076;qcseg=50075;qcseg=50074;qcseg=50073;qcseg=50062;qcseg=50060;qcseg=50059;qcseg=50057;qcseg=50054;"
    def data_values
      @data_values ||= JSON.parse(raw_data).map{|h| h['id']}
    end

    def raw_data_contains_some_info?
      calculated_gender.present? || calculated_household_income.present?
    end

    def calculated_gender
      male_matches = data_values & m('Male', "Male_21-34", "Male_25-54", "Male_35-54", "Male_21+", "Male_55+", "Male_18-24", "Male_18-34", "Male_18-49")
      female_matches = data_values & m("Female", "Female_21-34", "Female_18-24", "Female_18-34", "Female_18-49", "Female_21+", "Female_25-54", "Female_35-54", "Female_55+")

      if male_matches.count > 0 || female_matches.count > 0
        male_matches.count > female_matches.count ? 'male' : 'female'
      end
    end

    def calculated_household_income
      if (data_values & m('100K-')).present?
        '0-100k'
      elsif (data_values & m('100K+')).present?
        '100k+'
      end
    end

    def calculated_children
      if (data_values & m('Moms', 'Parents')).present?
        "true"
      elsif raw_data_contains_some_info?   # if other data is present, assume lack of this info is that they don't have children
        "false"
      end
    end

    def calculated_ethnicity
      if (data_values & m('Asian')).present?
        'asian'
      elsif (data_values & m('African_American')).present?
        'african_american'
      elsif (data_values & m('Hispanic')).present?
        'hispanic'
      elsif raw_data_contains_some_info?   # if other data is present, assume lack of this info is that they're caucasian
        'caucasian'
      end
    end

    def calculated_education_level
      if (data_values & m('College+')).present?
        'college'
      elsif raw_data_contains_some_info?
        'no_college'
      end
    end

    def calculated_political_affiliation
      # No mappings for this at this time (2/10/2015)
      nil
    end

    def calculated_political_engagement
      # No mappings for this at this time (2/10/2015)
      nil
    end

    def calculated_age_range
      age_interval = normalized_age_interval age_intervals

      if age_interval.present?
        tree = IntervalTree::Tree.new [(0...18), (18...25), (25...35), (35...45), (45...55), (55...105)]
        case tree.search age_interval
        when [0...18] then "<18"
        when [18...25] then "18-24"
        when [25...35] then "25-34"
        when [35...45] then "35-44"
        when [45...55] then "45-54"
        when [55...105] then "55+"
        end
      end
    end

    # Given a set of intervals, find smallest one that includes all of them, but
    # throwing out one at a time if they don't all overlap
    def normalized_age_interval intervals
      i = best_fit_age_interval intervals
      while intervals.count > 0 && i.nil?
        intervals.shift!
        i = best_fit_age_interval intervals
      end
      i
    end

    def best_fit_age_interval intervals
      if intervals.present?
        min = intervals.map{|i| i.min}.max
        max = intervals.map{|i| i.max}.min
        if min <= max
          (min...max)
        end
      end
    end

    def age_intervals
      keys = data_values & m("18-24", "18-34", "18-49", "21+", "25-54", "35-54", "55+", "21-34", "Male_21-34", "Male_25-54", "Male_35-54", "Male_21+", "Male_55+", "Male_18-24", "Male_18-34", "Male_18-49", "Female_21-34", "Female_18-24", "Female_18-34", "Female_18-49", "Female_21+", "Female_25-54", "Female_35-54", "Female_55+")
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
        when m("Male_21-34") then (21...35)
        when m("Male_25-54") then (25...55)
        when m("Male_35-54") then (35...55)
        when m("Male_21+") then (21...105)
        when m("Male_55+") then (55...105)
        when m("Male_18-24") then (18...25)
        when m("Male_18-34") then (18...35)
        when m("Male_18-49") then (18...50)
        when m("Female_21-34") then (21...35)
        when m("Female_18-24") then (18...25)
        when m("Female_18-34") then (18...35)
        when m("Female_18-49") then (18...50)
        when m("Female_21+") then (21...105)
        when m("Female_25-54") then (25...55)
        when m("Female_35-54") then (35...55)
        when m("Female_55+") then (55...105)
        end
      end
    end

    def m *keys
      keys.map{|key| mapping[key]}
    end

    # Map our values to the ids from the provider
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
        "College+" => "50062",
        "Moms" => "50078",
        "Parents" => "50079",
        "Male" => "50082",
        "Female" => "50083",
        "Male_21-34" => "50084",
        "Female_21-34" => "50085",
        "Male_25-54" => "50075",
        "Male_35-54" => "50076",
        "Male_21+" => "50074",
        "Male_55+" => "50077",
        "Male_18-24" => "50071",
        "Male_18-34" => "50072",
        "Male_18-49" => "50073",
        "Female_18-24" => "50063",
        "Female_18-34" => "50064",
        "Female_18-49" => "50065",
        "Female_21+" => "50066",
        "Female_25-54" => "50067",
        "Female_35-54" => "50068",
        "Female_55+" => "50069",
        "100K+" => "50054",
        "100K-" => "50081",
        "Asian" => "50087",
        "African_American" => "50080",
        "Hispanic" => "50070"
      }
    end
end
