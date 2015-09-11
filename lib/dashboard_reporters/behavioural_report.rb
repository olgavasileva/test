class BehaviouralReport < DashboardReport

  def initialize(date_range, user, emotional_report)
    super(date_range, user)
    @emotional_report = emotional_report
  end

  def get_report
    @report[:sessions] = sessions_count
    @report[:time_per_session] = time_per_session
    @report[:total_session_time] = @sessions_duration
    @report[:views] = views
    @report[:insights] = 0 #not implemented
    @report[:engagements] = @report[:insights] + @emotional_report[:notes] +
        @emotional_report[:reblogs] + @emotional_report[:reblogs]
    @report[:interaction_rate] = @report[:sessions] > 0 ? @report[:engagements].to_f / @report[:sessions] : 0
  end

  private

  def sessions_count
    count = 0
    mutex = Mutex.new
    threads = @user.question_ids.each_slice(QUESTIONS_LIMIT).map do |question_ids|
      Thread.new {
        response = get_google_response('start-date' => start_date.to_s,
                                       'end-date' => end_date.to_s,
                                       'dimensions' => 'ga:eventLabel',
                                       'filters' => "ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                       'metrics' => 'ga:sessions')
        mutex.synchronize {
          count += begin
            response.data['rows'].inject(0) { |result, x| result + x[2].to_i }
          rescue
            0
          end
        }
      }
    end

    threads.each(&:join)

    count
  end

  def time_per_session
    session_count = 0
    @sessions_duration = 0
    mutex = Mutex.new
    threads = @user.question_ids.each_slice(QUESTIONS_LIMIT).map do |question_ids|
      Thread.new {
        response = get_google_response('start-date' => start_date.to_s,
                                       'end-date' => end_date.to_s,
                                       'dimensions' => 'ga:eventLabel',
                                       'filters' => "ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                       'metrics' => 'ga:sessions,ga:sessionsDuration')
        mutex.synchronize {
          session_count += begin
            response.data['rows'].inject(0) { |result, x| result + x[1].to_i }
          rescue
            0
          end
          @sessions_duration += begin
            response.data['rows'].inject(0) { |result, x| result + x[2].to_i }
          rescue
            0
          end
        }
      }
    end

    threads.each(&:join)

    session_count == 0 ? 0 : (@sessions_duration.to_f / session_count).to_i
  end

  def views
    views = 0
    mutex = Mutex.new
    threads = @user.question_ids.each_slice(QUESTIONS_LIMIT).map do |question_ids|
      Thread.new {
        response = get_google_response('start-date' => start_date.to_s,
                                       'end-date' => end_date.to_s,
                                       'dimensions' => 'ga:eventLabel',
                                       'filters' => "ga:eventLabel=~#{join_regex_rules(question_ids)}",
                                       'metrics' => 'ga:pageviews')
        mutex.synchronize {
          views += begin
            response.data['rows'].inject(0) { |result, x| result + x[1].to_i }
          rescue
            0
          end
        }
      }
    end

    threads.each(&:join)

    views
  end

end