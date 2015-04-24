class TwoCents::API < Grape::API
  #prefix 'v'
  #version '2.0', using: :path
  format :json          # input must be json
  default_format :json  # assume json if no Content-Type is supplied
  default_error_formatter :json
  formatter :json, Grape::Formatter::Jbuilder

  before do
    @start = Time.now.to_f if ENV['API_LOG_LEVEL'] == 'debug'

    logger = Rails.configuration.logger || Rails.logger

    if ENV['API_LOG_LEVEL'] == 'debug'
      duration = (Time.now.to_f - @start) * 1000
      params = request.params.except('route_info').to_hash
      max_param_str_len = params.keys.map{|k|k.to_s.length}.max
      logger.info({
        api: "[#{status}] #{request.request_method} #{request.path}",
        duration: "#{duration.to_i} ms",
        ip: request.ip,
        user_agent: request.user_agent,
        params: params.map{|k,v| "\n#{'%2s' % ''}#{"%-#{max_param_str_len}.#{max_param_str_len}s " % k} #{v}"}.join(""),
      }.map{|k,v| "#{'%-20.20s' % k} #{v}"}.join("\n"))
    else
      logger.info "api: [#{status}] #{request.request_method} #{request.path}"
    end
  end

  after do
    if ENV['API_LOG_LEVEL'] == 'debug'
      logger = Rails.configuration.logger || Rails.logger
      duration = (Time.now.to_f - @start) * 1000
      logger.info({
        api: "[#{status}] #{request.request_method} #{request.path}",
        duration: "#{duration.to_i} ms",
      }.map{|k,v| "#{'%-20.20s' % k} #{v}"}.join("\n"))
    end
  end

  helpers do
    include Pundit
    include Gravatarify::Helper

    def declared_params
      declared(params, include_missing: false)
    end

    def app_version_compatible? app_version
      ENV['COMPATIBLE_APP_VERSION'].blank? || app_version == ENV['COMPATIBLE_APP_VERSION']
    end

    def anonymous_user! options = {}
      @current_user = Anonymous.create! options
    end

    def current_user
      @current_user ||= if params[:auth_token]
        @instance = Instance.find_by auth_token:params[:auth_token]
        fail! 402, "Invalid auth token" unless @instance
        @instance.user
      end
    end

    def validate_user!
      fail! 403, "Login required" unless current_user
    end

    def fail! code, message
      error!({error_message:message, error_code:code}, 200)
    end

    def send_email(email_address, message)
      UserMailer.notification(email_address, message).deliver
    end

    def send_sms(phone_num, message)
      twilio.account.sms.messages.create(
        from: "+1#{ENV['TWILIO_FROM']}",
        to: phone_num,
        body: message
      )
    end

    def twilio
      @twilio ||= Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH_TOKEN'])
    end
  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    Rack::Response.new({error_code: 400, error_message: e.message}.to_json, 200, "Content-Type" => "application/json").finish
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    Rack::Response.new({error_code: 401, error_message: e.message}.to_json, 200, "Content-Type" => "application/json").finish
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    Rack::Response.new({error_code: 499, error_message: e.message}.to_json, 200, "Content-Type" => "application/json").finish
  end

  unless Rails.env.development? || Rails.env.test?
    rescue_from :all do |e|
      Airbrake.notify_or_ignore(e, cgi_data: ENV.to_hash)
      Rack::Response.new({error_code: 500, error_message: "Something went wrong."}.to_json, 200, "Content-Type" => "application/json").finish
    end
  end

  mount Auth => '/v/2.0'
  mount Questions => '/v/2.0'
  mount Categories => '/v/2.0'
  mount Comments => '/v/2.0'
  mount Relationships => '/v/2.0'
  mount Groups => '/v/2.0'
  mount Messages => '/v/2.0'
  mount Studios => '/v/2.0'
  mount Profile => '/v/2.0'
  mount Communities => '/v/2.0'
  mount ImageSearch => '/v/2.0'
  mount Demographics => '/v/2.0'
  mount Tags => '/v/2.0'
  mount Surveys => '/v/2.0'
  mount Trending => '/v/2.0'

  add_swagger_documentation markdown:true, hide_documentation_path:true
end
