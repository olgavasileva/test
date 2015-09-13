require 'google/api_client'

class GoogleAnalyticsReporter
  attr_accessor :start_date, :end_date

  SERVICE_ACCOUNT_EMAIL_ADDRESS = '827188703427-v7km3qvj0hpkesukpdtpsujl4ga1rf8s@developer.gserviceaccount.com'.freeze
  PATH_TO_KEY_FILE = (Rails.root.join 'certs', 'StatisfyAnalyticsAPIClient-4b494c30b250.p12').freeze
  PROFILE = 'ga:96256016'.freeze

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

  def get_response(params)
    Rails.logger.info('GOOGLE ANALYTICS QUERY: ' + params.inspect)
    query_params = {api_method: api_method}.merge(parameters: params.merge('ids' => PROFILE))
    client.execute(query_params)
  end

end