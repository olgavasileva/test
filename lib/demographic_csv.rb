class DemographicCSV < Struct.new(:question)

  DEMOGRAPHICS = {
    age_range: 'Age',
    gender: 'Gender',
    children: 'Children in Household',
    household_income: 'Household Income',
    ethnicity: 'Ethnicity',
    education: 'Education Level',
    political_affiliation: 'Politicial Affiliation'
  }.freeze

  def self.export(question)
    csv = self.new(question)
    csv.to_csv
  end

  def to_csv
    CSV.generate do |csv|
      # Header
      csv << question_title_row
      choice_rows { |row| csv << row }

      # Spacer
      csv << []

      # Responses
      csv << question_title_row
      csv << response_title_row
      response_rows { |row| csv << row }
    end
  end

  def question_title_row
    ['Question', question.title]
  end

  def response_title_row
    choices.each_with_index.map do |choice, idx|
      "Option ##{idx +1}"
    end.push(*DEMOGRAPHICS.values)
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

  def response_rows(&block)
    question.responses.includes(:demographic).find_each do |response|
      data = response.csv_data

      if response.demographic.present?
        demo = response.demographic.attributes.slice(*DEMOGRAPHICS.keys).values
        data.push(*demo)
      end

      yield(data)
    end
  end
end
