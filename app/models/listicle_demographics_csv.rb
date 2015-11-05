class ListicleDemographicsCSV < DemographicCSV
  attr_accessor :listicle

  def initialize(listicle, options = {})
    @listicle = listicle
    @options = options
  end

  def to_csv
    CSV.generate col_sep: ',' do |csv|
      question_section csv
      csv << [] # Spacer
      responses_section csv
    end
  end

  def question_section csv
    # Build aggregated responses
    csv << ['Listicle:', listicle.get_intro.html_safe]
  end

  def responses_section csv
    # Restate the Question
    csv << ['Responses to:', listicle.get_intro]

    # Build responses header row
    columns = [nil]
    columns += DEMOGRAPHICS.values
    columns += %w(Score)

    csv << columns

    # Build a line for each response
    listicle.responses.each do |response|
      respondent = response.user
      demographic = respondent.demographic_summary
      if should_add_rows(demographic)
        begin
          line = [nil]
          line += if demographic
                    DEMOGRAPHICS.map { |key, _| demographic.send key }
                  else
                    Array.new(DEMOGRAPHICS.keys.count)
                  end
          line += response.csv_data

          csv << line
        rescue
        end
      end
    end
  end

end