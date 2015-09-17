class DashboardReport

  QUESTIONS_LIMIT = 10

  def initialize(date_range, user)
    @date_range, @user = date_range, user
    @google_reporter = GoogleAnalyticReporter.new
    set_report
  end

  def [](key)
    @report[key]
  end

  def to_h
    @report
  end

  def set_report
    unless @report
      @report = {}
      get_report
    end
    @report
  end

  private

  def get_report
    raise StandardError, 'Not Implemented'
  end

  def get_google_response(params)
    @google_reporter.get_response(params)
  end

  def tumblr_client
    @tumblr_client ||= Tumblr::Client.new(TUMBLER_KEYS)
  end

  def join_regex_rules(elements)
    '^' + elements.join('$|^') + '$'
  end

  def start_date
    @date_range.start_date
  end

  def end_date
    @date_range.end_date
  end

end