class BehaviouralReport < DashboardReport

  def initialize(date_range, user, emotional_report, options = {})
    @emotional_report = emotional_report
    super(date_range, user, options)
  end

  private

  def get_report
    @report[:sessions] = sessions_count
    @report[:time_per_session] = time_per_session
    @report[:total_session_time] = @sessions_duration
    @report[:views] = views
    @report[:insights] = insights
    @report[:engagements] = @report[:insights] + @emotional_report[:notes] + @emotional_report[:reblogs]
    @report[:interaction_rate] = @report[:sessions] > 0 ? @report[:engagements].to_f / @report[:sessions] : 0
  end

  def sessions_count
    count = 0
    @question_ids.each_slice(QUESTIONS_LIMIT).each do |question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventLabel',
                                     'filters' => "ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                     'metrics' => 'ga:sessions')
      count += begin
        response.data['rows'].inject(0) { |result, x| result + x[2].to_i }.to_i
      rescue
        0
      end
    end

    count
  end

  def time_per_session
    session_count = 0
    @sessions_duration = 0
    @question_ids.each_slice(QUESTIONS_LIMIT).each do |question_ids|
      response = get_google_response('start-date' => start_date.to_s,
                                     'end-date' => end_date.to_s,
                                     'dimensions' => 'ga:eventLabel',
                                     'filters' => "ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                     'metrics' => 'ga:sessions,ga:sessionsDuration')
      session_count += begin
        response.data['rows'].inject(0) { |result, x| result + x[1].to_i }.to_i
      rescue
        0
      end
      @sessions_duration += begin
        response.data['rows'].inject(0) { |result, x| result + x[2].to_i }.to_i
      rescue
        0
      end
    end

    session_count == 0 ? 0 : (@sessions_duration.to_f / session_count).to_i
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
        response.data['rows'].inject(0) { |result, x| result + x[1].to_i }.to_i
      rescue
        0
      end
    end

    views
  end

  def insights
    @surveys.includes(:questions => :responses)
        .flat_map { |survey| survey.questions.flat_map(&:responses) }.length
  end

end