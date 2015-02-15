class OmniauthController < ActionController::Base

  layout false

  # Require that a valid Instance be present and that either the retreived
  # Authentication or the valid Instance has a user associated with it.
  #
  before_action :require_instance!, only: [:callback]
  before_action :require_user!, only: [:callback]

  rescue_from ActiveRecord::ActiveRecordError do
    render_error t('omniauth.error.process_error')
  end

  # Authentication Flow
  #
  # 1. We have an Anonymous user
  #
  #   a. If we've authenticated them with this provider before, assign that
  #      previous user to the Instance and we're done.
  #   b. If we haven't authenticated them with this provider before, we promote
  #      the user using social credentials and store that info in the database
  #      to authenticate with later.
  #
  # 2. We have a registered user.
  #
  #   a. If the Authtentication has a User record associated with it, we assign
  #      the user to the current Instance...
  #   b. Otherwise, we do the opposite, assigning the user for the current
  #      Instance to the Authencitation record.
  #
  # Result:
  #
  # Returns information about the instance after it has been manipulated to be
  # associated with the correct user.
  #
  def callback
    Authentication.transaction do
      if instance.user.is_a?(Anonymous)
        if auth.user.present?
          instance.user = auth.user
        else
          password = SecureRandom.hex(16)
          auth.user = instance.user.promote!({
            name: auth_hash.name,
            password: password,
            password_confirmation: password
          })
        end
      elsif instance.user.present?
        auth.user = instance.user
      else
        instance.user = auth.user
      end

      auth.save!
      instance.refresh_auth_token
      instance.save!
    end

    @data = {
      success: true,
      auth_token: instance.auth_token,
      email: instance.user.email,
      username: instance.user.username,
      user_id: instance.user.id
    }

    render :callback
  end

  def failure
    render_error params[:message]
  end

  private

  def require_instance!
    unless instance.present?
      render_error t('omniauth.error.instance_required')
    end
  end

  def require_user!
    unless auth.user.present? || instance.user.present?
      render_error t('omniauth.error.missing_user')
    end
  end

  def render_error(message)
    @data = {success: false, error: message}
    render :callback
  end

  def instance
    return @instance if defined?(@instance)
    token = (params[:instance_token] || auth_params['instance_token'])
    @instance = token.present? && Instance.find_by(uuid: token)
  end

  def auth
    @auth ||= Authentication.from_omniauth(auth_hash)
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def auth_params
    request.env['omniauth.params']
  end
end
