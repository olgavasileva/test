client =

module SocialProfile
  class TwitterAdapter < BaseAdapter

    def valid?
      token.present? && secret.present? && uid.present?
    end

    def provider
      'twitter'
    end

    def uid
      profile.id
    end

    def first_name
      name.split(' ').first
    end

    def last_name
      name.split(' ', 2).last
    end

    def name
      profile.name
    end

    def username
      profile.screen_name
    end

    private

    def client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_API_KEY']
        config.consumer_secret = ENV['TWITTER_API_SECRET']
        config.access_token = token
        config.access_token_secret = secret
      end
    end

    def profile
      return @profile if defined?(@profile)
      @profile = begin
        client.user
      rescue Twitter::Error => e
        Twitter::User.new({id: nil})
      end
    end
  end
end
