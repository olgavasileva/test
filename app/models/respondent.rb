class Respondent < ActiveRecord::Base
  self.table_name = 'users'

  VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
  validates :username,
              presence: true,
              format: { with: VALID_USERNAME_REGEX },
              length: { maximum: 50 },
              uniqueness: { case_sensitive: false }

  before_validation :ensure_username

  default :auth_token do |user|
    Respondent.generate_auth_token
  end

  def regenerate_auth_token
    self.auth_token = Respondent.generate_auth_token
  end

  private
    def self.generate_auth_token
      "A"+UUID.new.generate
    end

    def ensure_username
      if username.nil?
        self.username = random_username
        while Respondent.find_by(username:self.username).present?
          self.username = random_username
        end
      end
    end

    COLORS = %w(Red Green Blue Teal Orange Tangerine Yellow Black White Purple Brown)
    ANIMALS = %w(Beaver Otter Dog Cat Mouse Bird Gopher Marlin Magpie)

    def random_username
      COLORS.sample + ANIMALS.sample + random_number(rand(2..5))
    end

    def random_number digits
      Random.new.rand(10**(digits-1)..10**digits-1).to_s
    end
end