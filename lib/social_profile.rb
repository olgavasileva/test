require 'social_profile/base_adapter'
require 'social_profile/facebook_adapter'

module SocialProfile

  def self.build(provider=nil, token)
    adapter = self.provider_adapter(provider)
    adapter.new(token)
  end

  private

  def self.provider_adapter(provider)
    case provider.to_s.downcase
    when 'facebook'
      FacebookAdapter
    else
      BaseAdapter
    end
  end
end
