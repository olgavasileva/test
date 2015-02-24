class DemographicSummary < DemographicBase
  validates :respondent, uniqueness: true

  def calculate!
    respondent.demographics.includes(:data_provider).order("data_providers.priority asc").each do |d|
      attributes.keys.reject{|attr| attr == 'id'}.each do |attr|
        self[attr] = d[attr] if self[attr].nil?
      end
    end
    save!
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

  def self.use_sample_data= bool
    @use_sample_data = bool
  end

  def self.use_sample_data?
    !!@use_sample_data
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
      age_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.age_range").count.except nil
      age_count = age_info.values.sum.to_f

      { id: "AGE", name: "Age", buckets:
        [
          info("<18", age_info['<18'].to_i, age_count),
          info('18-24', age_info['18-24'].to_i, age_count),
          info('25-34', age_info['25-34'].to_i, age_count),
          info('35-44', age_info['35-44'].to_i, age_count),
          info('45-54', age_info['45-54'].to_i, age_count),
          info('55+', age_info['55+'].to_i, age_count)
        ].sort_by{|i| [-i[:index],i[:name]]}
      }
    end

    def self.gender_info question_or_choice
      gender_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.gender").count.except nil
      gender_count = gender_info.values.sum.to_f

      { id: "GENDER", name: "Gender", buckets:
        [
          info('male', gender_info['male'].to_i, gender_count),
          info('female', gender_info['female'].to_i, gender_count)
        ].sort_by{|i| [-i[:index],i[:name]]}
      }
    end

    def self.children_info question_or_choice
      children_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.children").count.except nil
      children_count = children_info.values.sum.to_f

      { id: "CHILDREN", name: "Children in Household", buckets:
        [
          info('children', children_info['true'].to_i, children_count),
          info('no_children', children_info['false'].to_i, children_count)
        ].sort_by{|i| [-i[:index],i[:name]]}
      }
    end

    def self.income_info question_or_choice
      income_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.household_income").count.except nil
      income_count = income_info.values.sum.to_f

      { id: "INCOME", name: "Household Income", buckets:
        [
          info('0-100k', income_info["0-100k"].to_i, income_count),
          info('100k+', income_info["100k+"].to_i, income_count)
        ].sort_by{|i| [-i[:index],i[:name]]}
      }
    end

    def self.education_info question_or_choice
      education_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.education_level").count.except nil
      education_count = education_info.values.sum.to_f

      { id: "EDUCATION", name: "Education Level", buckets:
        [
          info('college', education_info["college"].to_i, education_count),
          info('no_college', education_info["no_college"].to_i, education_count)
        ].sort_by{|i| [-i[:index],i[:name]]}
      }
    end

    def self.ethnicity_info question_or_choice
      ethnicity_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.ethnicity").count.except nil
      ethnicity_count = ethnicity_info.values.sum.to_f

      { id: "ETHNICITY", name: "Ethnicity", buckets:
        [
          info('hispanic', ethnicity_info["hispanic"].to_i, ethnicity_count),
          info('asian', ethnicity_info["asian"].to_i, ethnicity_count),
          info('african_american', ethnicity_info["african_american"].to_i, ethnicity_count),
          info('caucasian', ethnicity_info["caucasian"].to_i, ethnicity_count)
        ].sort_by{|i| [-i[:index],i[:name]]}
      }
    end

    def self.political_affiliation_info question_or_choice
      political_affiliation_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.political_affiliation").count.except nil

      { id: "AFFILIATION", name: "Political Affiliation", buckets: []}
    end

    def self.political_engagement_info question_or_choice
      political_engagement_info = question_or_choice.responses.joins(:user).joins(:demographic_summary).group("demographic_summaries.political_engagement").count.except nil

      { id: "ENGAGEMENT", name: "Political Engagement", buckets: []}
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

        "<18" => "0-18",
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
