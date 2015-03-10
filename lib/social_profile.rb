require 'social_profile/base_adapter'
require 'social_profile/facebook_adapter'
require 'social_profile/twitter_adapter'

module SocialProfile

  def self.build(provider=nil, token=nil, secret=nil)
    adapter = self.provider_adapter(provider)
    adapter.new(token, secret)
  end

  private

  def self.provider_adapter(provider)
    case provider.to_s.downcase
    when 'facebook'
      FacebookAdapter
    when 'twitter'
      TwitterAdapter
    else
      BaseAdapter
    end
  end
end
