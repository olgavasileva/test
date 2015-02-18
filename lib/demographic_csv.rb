class DemographicCSV < Struct.new(:question)

  DEMOGRAPHICS = {
    gender: 'Gender',
    age_range: 'Age',
    household_income: 'Household Income',
    children: 'Children in Household',
    ethnicity: 'Ethnicity',
    education_level: 'Education Level',
    political_affiliation: 'Politicial Affiliation',
    political_engagement: 'Politicial Engagement'
  }.freeze

  def self.export(question)
    csv = self.new(question)
    csv.to_csv
  end

  def to_csv
    CSV.generate do |csv|
      # Build aggregated responses
      csv << ['Question:', question.title]
      choice_rows { |row| csv << row }
      csv << []   # Spacer

      # Restate the Question
      csv << ['Responses to:', question.title]

      # Build responses header row
      columns = DEMOGRAPHICS.values
      columns += question.csv_columns

      csv << columns

      # Build a line for each response
      question.responses.each do |response|
        respondent = response.user
        demographic = respondent.demographic
        line = if demographic
          DEMOGRAPHICS.map{|key,label| demographic[key]}
        else
          Array.new(DEMOGRAPHICS.keys.count)
        end
        line += response.csv_data

        csv << line
      end
    end
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
