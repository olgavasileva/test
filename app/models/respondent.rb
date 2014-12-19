class Respondent < ActiveRecord::Base
  self.table_name = 'users'

  VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
  validates :username,
              presence: true,
              format: { with: VALID_USERNAME_REGEX },
              length: { maximum: 50 },
              uniqueness: { case_sensitive: false }

  before_validation :ensure_username

  private
    def ensure_username
      if username.nil?
        self.username = random_username
        while Respondent.find_by(username:self.username).present?
          self.username = random_username
        end
      end
    end

    COLORS = %w(red green blue teal orange tangerine yellow black white purple brown)
    ANIMALS = %w(beaver otter dog cat mouse bird gopher marlin magpie)

    def random_username
      COLORS.sample + ANIMALS.sample + random_number(3)
    end

    def random_number digits
      Random.new.rand(10**(digits-1)..10**digits-1).to_s
    end
end