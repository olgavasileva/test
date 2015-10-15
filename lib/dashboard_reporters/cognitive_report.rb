class CognitiveReport < DashboardReport

  def get_report
    @report[:viral_factor] = viral_factor
    @report[:revisit_rate] = revisit_rate
  end

  private

  def viral_factor
    1 + if views > 0
          unique_referrers * shares.to_f / views
        else
          0
        end
  end

  def views
    views = 0
    @question_ids.each_slice(QUESTIONS_LIMIT).each do |question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventLabel',
                                     'filters' => "ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                     'metrics' => 'ga:pageviews')
      views += begin
        response.data['rows'].map { |x| x[1].to_i }.inject(:+).to_i
      rescue
        0
      end
    end

    views
  end

  def unique_referrers
    @user.surveys.includes(:questions => :responses)
        .map { |survey| survey.questions.map(&:unique_referrers) }.flatten.count
  end

  def shares
    shares = 0
    @question_ids.each_slice(QUESTIONS_LIMIT).each do |question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:socialInteractionTarget,socialInteractionAction',
                                     'filters' => "ga:socialInteractionAction=share;ga:socialInteractionTarget=~#{join_regex_rules(question_ids)}",
                                     'metrics' => 'ga:socialInteractions')
      shares += begin
        response.data['rows'].map { |x| x[2].to_i }.inject(:+).to_i
      rescue
        0
      end
    end

    shares
  end

  def revisit_rate
    0 # not implemented
  end

end