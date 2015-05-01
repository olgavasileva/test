class DemographicCSV < Struct.new(:question, :options)

  DEMOGRAPHICS = {
    gender: 'Gender',
    age_range: 'Age',
    household_income: 'Household Income',
    children: 'Children in Household',
    ethnicity: 'Ethnicity',
    education_level: 'Education Level',
    # political_affiliation: 'Politicial Affiliation',
    # political_engagement: 'Politicial Engagement',
    latitude: 'Latitude',
    longitude: 'Longitude',
    metro_code: 'Metro Code',
    city: 'City',
    state: 'State',
    postal_code: 'Postal Code',
    country: 'Country'
  }.freeze

  def self.export(question, options = {})
    csv = self.new(question, options)
    csv.to_csv
  end

  def to_csv
    CSV.generate do |csv|
      question_section csv
      csv << []   # Spacer
      responses_section csv
      csv << []   # Spacer
      comments_section csv
    end
  end

  def question_section csv
    # Build aggregated responses
    csv << ['Question:', question.title]
    choice_rows { |row| csv << row }
  end

  def responses_section csv
    # Restate the Question
    csv << ['Responses to:', question.title]

    # Build responses header row
    columns = [nil]
    columns += DEMOGRAPHICS.values
    columns += question.csv_columns

    csv << columns

    # Build a line for each response
    question.responses.each do |response|
      respondent = response.user
      demographic = respondent.demographic_summary
      unless options[:us_only] && demographic && demographic.country != "US"
        line = [nil]
        line += if demographic
          DEMOGRAPHICS.map{|key,label| demographic.send key}
        else
          Array.new(DEMOGRAPHICS.keys.count)
        end
        line += response.csv_data

        csv << line
      end
    end
  end

  def comments_section csv
    csv << ["Comments:"]
    csv << ["Comment"] + DEMOGRAPHICS.values

    # Build lines for each question comment and subcomments
    question.comments.find_each do |comment|
      comment_lines(comment).each do |line|
        csv << line
      end
    end

    # Build lines for each response comment and subcomments
    question.response_comments.find_each do |comment|
      comment_lines(comment).each do |line|
        csv << line
      end
    end
  end

  # Recursively generate all comment lines including comments on comments
  def comment_lines comment
    respondent = comment.user
    demographic = respondent.demographic_summary

    lines = []

    unless options[:us_only] && demographic && demographic.country != "US"
      line = [comment.body]
      line += if demographic
        DEMOGRAPHICS.map{|key,label| demographic.send key}
      else
        Array.new(DEMOGRAPHICS.keys.count)
      end

      lines << line
      comment.comments.find_each do |c|
        lines += comment_lines c
      end
    end

    lines
  end

  def choices
    @choices ||= if question.is_a?(ChoiceQuestion)
      question.choices.order(:id)
    else
      Choice.none
    end
  end

  def choice_rows(&block)
    choices.each_with_index do |choice, idx|
      yield([
        "Option ##{idx+1}",
        choice.title,
        "%d%" % (choice.response_ratio * 100),
        choice.try(:web_image_url)
      ])
    end
  end
end
