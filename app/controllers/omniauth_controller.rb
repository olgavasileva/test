class OmniauthController < ActionController::Base

  layout false

  before_action :require_instance!, only: [:callback]

  def callback
    @data = {
      success: true,
      auth: {provider: auth_hash.provider, token: auth_hash.credentials.token}
    }

    render :callback
  end

  def failure
    @data = {success: false, error: params[:message]}
    render :callback
  end

  private

  def require_instance!
    unless instance.present?
      @data = {success: false, error: 'Instance token required'}
      render :callback
    end
  end

  def instance
    return @instance if defined?(@instance)
    token = (params[:instance_token] || auth_params['instance_token'])
    @instance = token.present? && Instance.find_by(uuid: token)
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def auth_params
    request.env['omniauth.params']
  end
end
