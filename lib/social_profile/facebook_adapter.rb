module SocialProfile
  class FacebookAdapter < BaseAdapter

    def valid?
      token.present? && !profile.empty?
    end

    def provider
      'facebook'
    end

    def uid
      profile['id']
    end

    def first_name
      profile['first_name']
    end

    def last_name
      profile['last_name']
    end

    def name
      [first_name, last_name].compact.join(' ')
    end

    def username
      [first_name, last_name].compact.join('').downcase
    end

    def email
      profile['email']
    end

    def gender
      profile['gender'] if %w{male female}.include?(profile['gender'])
    end

    def birthdate
      profile['birthday']
    end

    private

    def client
      @client ||= Koala::Facebook::API.new(token)
    end

    def profile
      return @profile if defined?(@profile)
      @profile = begin
        client.get_object('me')
      rescue Koala::Facebook::APIError => e
        {}
      end
    end
  end
end
