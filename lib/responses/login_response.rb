class LoginResponse

  def self.respond_with(instance, auth=nil)
    self.new(instance, auth).to_hash
  end

  attr_reader :instance, :auth

  def initialize(instance, auth=nil)
    @instance = instance
    @auth = auth
  end

  def user
    instance.user
  end

  def to_hash
    {}.tap do |atts|
      atts.merge!(instance_atts) if user.present?
      atts.merge!(provider_atts) if user.respond_to?(:authentications)
      atts.merge!(auth_atts) if auth.present?
    end
  end

  def as_json
    to_hash.as_json
  end

  def to_json
    to_hash.to_json
  end

  private

  def instance_atts
    {
      auth_token: instance.auth_token,
      user_id: user.try(:id),
      username: user.try(:username),
      email: user.try(:email)
    }
  end

  def provider_atts
    {
      providers: user.authentications.as_json(only: [:id, :provider])
    }
  end

  def auth_atts
    {
      success: auth.user.present?,
      provider_valid: true,
      provider_id: auth.id
    }
  end
end
