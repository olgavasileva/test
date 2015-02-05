module SocialProfile
  class BaseAdapter

    attr_reader :token

    def initialize(token=nil)
      @token = token
    end

    def provider
      'base'
    end

    def valid?
      false
    end

    def uid; nil; end
    def first_name; nil; end
    def last_name; nil; end
    def name; nil; end
    def username; nil; end
    def email; nil; end
    def gender; nil; end
    def birthdate; nil end
  end
end
