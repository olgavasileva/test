require 'google/api_client'

class GoogleAnalyticsReporter
  attr_accessor :start_date, :end_date

  SERVICE_ACCOUNT_EMAIL_ADDRESS = '827188703427-v7km3qvj0hpkesukpdtpsujl4ga1rf8s@developer.gserviceaccount.com'.freeze
  PATH_TO_KEY_FILE = (Rails.root.join 'certs', 'StatisfyAnalyticsAPIClient-4b494c30b250.p12').freeze
  PROFILE = 'ga:96256016'.freeze

  QUESTIONS_LIMIT = 10

  def initialize(user, params = {})
    @user = user
    @start_date = params[:start_date] || Date.today - 5.years
    @end_date = params[:end_date] || Date.today
    @question_ids = params[:question_ids]

    if @question_ids
      @survey_main_questions_ids = @question_ids
    end
  end

  def report
    report = {}

    response = get_response('start-date' => start_date.to_s,
                            'end-date' => end_date.to_s,
                            'dimensions' => 'ga:eventCategory,ga:eventAction',
                            'filters' => "ga:eventAction==view;ga:eventCategory==webapp;ga:eventLabel=~#{question_ids.join('$|')}",
                            'metrics' => 'ga:totalEvents')

    report[:views] = begin
      response.data['totalsForAllResults']['ga:totalEvents'].to_i
    rescue
      0
    end

    response = get_response('start-date' => start_date.to_s,
                            'end-date' => end_date.to_s,
                            'dimensions' => 'ga:eventCategory,ga:eventAction',
                            'filters' => "ga:eventAction==share;ga:eventCategory==webapp;ga:eventLabel=~#{question_ids.join('$|')}",
                            'metrics' => 'ga:totalEvents')

    report[:shares] = begin
      response.data['totalsForAllResults']['ga:totalEvents'].to_i
    rescue
      0
    end

    response = get_response('start-date' => start_date.to_s,
                            'end-date' => end_date.to_s,
                            'dimensions' => 'ga:eventCategory,ga:eventAction',
                            'filters' => "ga:eventAction==end;ga:eventCategory==webapp;ga:eventLabel=~#{survey_main_questions_ids.join('$|')}",
                            'metrics' => 'ga:totalEvents')

    report[:completes] = begin
      response.data['totalsForAllResults']['ga:totalEvents'].to_i
    rescue
      0
    end

    response = get_response('start-date' => start_date.to_s,
                            'end-date' => end_date.to_s,
                            'dimensions' => 'ga:eventCategory,ga:eventLabel',
                            'filters' => "ga:eventCategory==webapp;ga:eventLabel=~#{question_ids.join('$|')}",
                            'metrics' => 'ga:sessions')

    report[:traffic] = begin
      response.data['rows'].inject(0) { |result, x| result + x[2].to_i }
    rescue
      0
    end

    report[:time] = 0 #for now we are not tracking this parameter
    report
  end

  def between_dates(start_date, end_date)
    @start_date, @end_date = start_date, end_date
    self
  end

  private

  def question_ids
    @question_ids ||= @user.questions.limit(QUESTIONS_LIMIT).pluck(:id)
  end

  def survey_main_questions_ids
    @survey_main_questions_ids ||= @user.surveys.limit(QUESTIONS_LIMIT)
                                       .map { |survey| survey.questions.first }.compact.map(&:id)
  end

  def get_response(params)
    query_params = {api_method: api_method}.merge(parameters: params.merge('ids' => PROFILE))
    client.execute(query_params)
  end

  def client
    self.class.client
  end

  def api_method
    self.class.api_method
  end

  def self.client
    @client ||= begin
      client = Google::APIClient.new(
          :application_name => 'speedy-bonsai-87321',
          :application_version => '0.01'
      )
      client.authorization = Signet::OAuth2::Client.new(
          :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
          :audience => 'https://accounts.google.com/o/oauth2/token',
          :scope => 'https://www.googleapis.com/auth/analytics.readonly',
          :issuer => SERVICE_ACCOUNT_EMAIL_ADDRESS,
          :signing_key => Google::APIClient::PKCS12.load_key(PATH_TO_KEY_FILE, 'notasecret')
      ).tap { |auth| auth.fetch_access_token! }
      client
    end
  end

  def self.api_method
    @api_method ||= client.discovered_api('analytics', 'v3').data.ga.get
  end

end