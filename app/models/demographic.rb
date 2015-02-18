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

  def self.use_sample_data= bool
    @use_sample_data = bool
  end

  def self.use_sample_data?
    !!@use_sample_data
  end

  ##
  ## Aggregate methods for summarizing the demographics.
  ## The format of the aggregate data matches that of quantcast's aggregate data since we already had view code that consumes that format.
  ##

  def self.aggregate_data_for_question question
    { question: question }.merge(aggregate_data_for(question))
  end

  def self.aggregate_data_for_choice choice
    { choice: choice }.merge(aggregate_data_for(choice))
  end



  private

    def self.aggregate_data_for question_or_choice
      if use_sample_data?
        sample_data
      else
        {
          "GENDER" => self.merge_largest_bucket(self.gender_info(question_or_choice)),
          "AGE" => self.merge_largest_bucket(self.age_info(question_or_choice)),
          "CHILDREN" => self.merge_largest_bucket(self.children_info(question_or_choice)),
          "INCOME" => self.merge_largest_bucket(self.income_info(question_or_choice)),
          "EDUCATION" => self.merge_largest_bucket(self.education_info(question_or_choice)),
          "ETHNICITY" => self.merge_largest_bucket(self.ethnicity_info(question_or_choice)),
          "AFFILIATION" => self.merge_largest_bucket(self.political_affiliation_info(question_or_choice)),
          "ENGAGEMENT" => self.merge_largest_bucket(self.political_engagement_info(question_or_choice))
        }
      end
    end

    def self.info key, value, count
      name = label key
      index = index key, value, count
      percent = percent value, count

      { name: name, index: index, percent: percent }
    end

    def self.index key, value, count
      average = us_average key
      sample = percent value, count

      if sample <= average
        # 0 .. 100
        100 * sample / average
      else
        # 100 .. 200
        100 + 100 * (sample - average) / (1 - average)
      end
    end

    def self.percent value, count
      count > 0 ? value.to_f / count : 0
    end

    def self.merge_largest_bucket info
      largest = info[:buckets].sort_by{|b| b[:index]}.last
      info.merge(largest_bucket: largest)
    end

    def self.age_info question_or_choice
      age_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.age_range").count.except nil
      age_count = age_info.values.sum.to_f

      { id: "AGE", name: "Age", buckets:
        [
          info("<18", age_info['<18'].to_i, age_count),
          info('18-24', age_info['18-24'].to_i, age_count),
          info('25-34', age_info['25-34'].to_i, age_count),
          info('35-44', age_info['35-44'].to_i, age_count),
          info('45-54', age_info['45-54'].to_i, age_count),
          info('55+', age_info['55+'].to_i, age_count)
        ]
      }
    end

    def self.gender_info question_or_choice
      gender_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.gender").count.except nil
      gender_count = gender_info.values.sum.to_f

      { id: "GENDER", name: "Gender", buckets:
        [
          info('male', gender_info['male'].to_i, gender_count),
          info('female', gender_info['female'].to_i, gender_count)
        ]
      }
    end

    def self.children_info question_or_choice
      children_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.children").count.except nil
      children_count = children_info.values.sum.to_f

      { id: "CHILDREN", name: "Children in Household", buckets:
        [
          info('children', children_info['true'].to_i, children_count),
          info('no_children', children_info['false'].to_i, children_count)
        ]
      }
    end

    def self.income_info question_or_choice
      income_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.household_income").count.except nil
      income_count = income_info.values.sum.to_f

      { id: "INCOME", name: "Household Income", buckets:
        [
          info('0-100k', income_info["0-100k"].to_i, income_count),
          info('100k+', income_info["100k+"].to_i, income_count)
        ]
      }
    end

    def self.education_info question_or_choice
      education_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.education_level").count.except nil
      education_count = education_info.values.sum.to_f

      { id: "EDUCATION", name: "Education Level", buckets:
        [
          info('college', education_info["college"].to_i, education_count),
          info('no_college', education_info["no_college"].to_i, education_count)
        ]
      }
    end

    def self.ethnicity_info question_or_choice
      ethnicity_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.ethnicity").count.except nil
      ethnicity_count = ethnicity_info.values.sum.to_f

      { id: "ETHNICITY", name: "Ethnicity", buckets:
        [
          info('hispanic', ethnicity_info["hispanic"].to_i, ethnicity_count),
          info('asian', ethnicity_info["asian"].to_i, ethnicity_count),
          info('african_american', ethnicity_info["african_american"].to_i, ethnicity_count),
          info('caucasian', ethnicity_info["caucasian"].to_i, ethnicity_count)
        ]
      }
    end

    def self.political_affiliation_info question_or_choice
      political_affiliation_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.political_affiliation").count.except nil

      { id: "AFFILIATION", name: "Political Affiliation", buckets: []}
    end

    def self.political_engagement_info question_or_choice
      political_engagement_info = question_or_choice.responses.joins(:user).joins(:demographic).group("demographics.political_engagement").count.except nil

      { id: "ENGAGEMENT", name: "Political Engagement", buckets: []}
    end

    ##
    ## Data parsing methods
    ##

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
        intervals.shift
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

    def self.us_average key
      @us_average ||= {
        "male" => 0.49,
        "female" => 0.51,
        "<18" => 0.18,
        "18-24" => 0.12,
        "25-34" => 0.17,
        "35-44" => 0.19,
        "45-54" => 0.17,
        "55+" => 0.16,
        "0-100k" => 0.80,
        "100k+" => 0.20,
        "children" => 0.50,
        "no_children" => 0.50,
        "caucasian" => 0.76,
        "african_american" => 0.09,
        "asian" => 0.04,
        "hispanic" => 0.09,
        "other_ethnicity" => 0.01,
        "no_college" => 0.45,
        "college" => 0.55,
        "republican" => 0.48,
        "democrat" => 0.48,
        "independent" => 0.04,
        "active" => 0.20,
        "somewhat_active" => 0.20,
        "inactive" => 0.60
      }

      @us_average[key]
    end

    def self.label key
      @label ||= {
        "male" => "Male",
        "female" => "Female",

        "<18" => "< 18",
        "18-24" => "18-24",
        "25-34" => "25-34",
        "35-44" => "35-44",
        "45-54" => "45-54",
        "55+" => "55+",

        "0-100k" => "$0-$100k",
        "100k+" => "$100k+",

        "no_children" => "No Kids",
        "children" => "Has Kids",

        "caucasian" => "Caucasian",
        "african_american" => "African American",
        "asian" => "Asian",
        "hispanic" => "Hispanic",
        "other_ethnicity" => "Other",

        "no_college" => "No College",
        "college" => "College",

        "republican" => "Republican",
        "democrat" => "Democrat",
        "independent" => "Independent",

        "active" => "Active",
        "somewhat_active" => "Somewhat Active",
        "inactive" => "Inactive"
      }

      @label[key]
    end


    def self.sample_data
      {
        "GENDER" => {
          id: "GENDER",
          name: "Gender",
          buckets: [
            { index: 55, name: "Male", percent: 0.26822730898857117 },
            { index: 143, name: "Female", percent: 0.7317727208137512 }
          ],
          largest_bucket: { index: 143, name: "Female", percent: 0.7317727208137512 }
        },

        "AGE" => {
          id: "AGE",
          name: "Age",
          buckets: [
            { index: 27, name: "< 18", percent: 0.04899810999631882 },
            { index: 107, name: "18-24", percent: 0.13299041986465454 },
            { index: 149, name: "25-34", percent: 0.25696510076522827 },
            { index: 112, name: "35-44", percent: 0.2150430679321289 },
            { index: 120, name: "45-54", percent: 0.20722565054893494 },
            { index: 91, name: "55-64", percent: 0.09127848595380783 },
            { index: 86, name: "65+", percent: 0.047499194741249084 }
          ],
          largest_bucket: { index: 149, name: "25-34", percent: 0.25696510076522827 }
        },

        "MALEAGE" => {
          id: "MALEAGE",
          name: "Age for Males",
          buckets: [
            { index: 14, name: "Male < 18", percent: 0.01279696449637413 },
            { index: 50, name: "Male 18-24", percent: 0.03250908479094505 },
            { index: 68, name: "Male 25-34", percent: 0.06046846881508827 },
            { index: 60, name: "Male 35-44", percent: 0.05879722535610199 },
            { index: 67, name: "Male 45-54", percent: 0.0578799769282341 },
            { index: 59, name: "Male 55-64", percent: 0.029282033443450928 },
            { index: 69, name: "Male 65+", percent: 0.016485659405589104 }
          ],
          largest_bucket: { index: 69, name: "Male 65+", percent: 0.016485659405589104 }
        },

        "FEMALEAGE" => {
          id: "FEMALEAGE",
          name: "Age for Females",
          buckets: [
            { index: 41, name: "Female < 18", percent: 0.03620114177465439 },
            { index: 168, name: "Female 18-24", percent: 0.10048133134841919 },
            { index: 236, name: "Female 25-34", percent: 0.1964966207742691 },
            { index: 165, name: "Female 35-44", percent: 0.15624584257602692 },
            { index: 173, name: "Female 45-54", percent: 0.14934568107128143 },
            { index: 121, name: "Female 55-64", percent: 0.0619964525103569 },
            { index: 98, name: "Female 65+", percent: 0.03101353533565998 }
          ],
          largest_bucket: { index: 173, name: "Female 45-54", percent: 0.14934568107128143 }
        },

        "CHILDREN" => {
          id: "CHILDREN",
          name: "Children in Household",
          buckets: [
            { index: 129, name: "No Kids ", percent: 0.6508865356445312 },
            { index: 71, name: "Has Kids ", percent: 0.34911346435546875 }
          ],
          largest_bucket: { index: 129, name: "No Kids ", percent: 0.6508865356445312 }
        },

        "INCOME" => {
          id: "INCOME",
          name: "Household Income",
          buckets: [
            { index: 96, name: "$0-50k", percent: 0.4860217571258545 },
            { index: 102, name: "$50-100k", percent: 0.2973894476890564 },
            { index: 117, name: "$100-150k", percent: 0.14187024533748627 },
            { index: 89, name: "$150k+", percent: 0.07471854984760284 }
          ],
          largest_bucket: { index: 117, name: "$100-150k", percent: 0.14187024533748627 }
        },

        "EDUCATION" => {
          id: "EDUCATION",
          name: "Education Level",
          buckets: [
            { index: 73, name: "No College", percent: 0.3260171711444855 },
            { index: 121, name: "College", percent: 0.4927719235420227 },
            { index: 126, name: "Grad School", percent: 0.18121090531349182 }
          ],
          largest_bucket: { index: 126, name: "Grad School", percent: 0.18121090531349182 }
        },

        "ETHNICITY" => {
          id: "ETHNICITY",
          name: "Ethnicity",
          buckets: [
            { index: 103, name: "Caucasian", percent: 0.7807833552360535 },
            { index: 96, name: "African American", percent: 0.08745797723531723 },
            { index: 81, name: "Asian", percent: 0.03431972861289978 },
            { index: 88, name: "Hispanic", percent: 0.0832706093788147 },
            { index: 101, name: "Other", percent: 0.014168291352689266 }
          ],
          largest_bucket: { index: 103, name: "Caucasian", percent: 0.7807833552360535 }
        }
      }
    end
end
