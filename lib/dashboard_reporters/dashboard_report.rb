class DashboardReport

  QUESTIONS_LIMIT = 10

  def initialize(date_range, user)
    @date_range, @user = date_range, user
    @google_reporter = GoogleAnalyticsReporter.new
  end

  def get_report
    raise StandardError, 'Not Implemented'
  end

  def [](key)
    unless @report
      @report = {}
      get_report
    end
    @report[key]
  end

  private

  def get_google_response(params)
    @google_reporter.get_response(params)
  end

  def tumblr_client
    @tumblr_client ||= Tumblr::Client.new(TUMBLER_KEYS)
  end

  def join_regex_rules(elements)
    '^' + elements.join('$|^').chomp
  end

  def start_date
    @date_range.start_date
  end

  def end_date
    @date_range.end_date
  end

end