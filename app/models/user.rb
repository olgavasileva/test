class User < Respondent
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable,
         authentication_keys:[:login], reset_password_keys:[:login]

  belongs_to :avatar, class_name: "UserAvatar", foreign_key: :user_avatar_id



  # Allow user to log in using username OR email in the 'login' text area
	# https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  # Allow user to reset their password using username OR email in the 'login' text area
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
	attr_accessor :login

	has_many :authentications, dependent: :destroy

	before_create :create_remember_token

	validates :username, presence: true
	validates :name, length: { maximum: 50 }
	validates :terms_and_conditions, acceptance: true
  validates :gender, inclusion: {in: %w(male female), allow_nil: true}
  validates :birthdate, presence: true, on: :create
  # validate :over_13   # Disable for now (11/29/14) for General Mills pilot project

  def self.anonymous_user
    @anonymous_user ||= User.find_by username:"anonymous"
    if @anonymous_user.nil?
      @anonymous_user = User.new username:"anonymous", email:"anonymous@statisfy.co"
      @anonymous_user.save validate:false
    end
    @anonymous_user
  end

  def anonymous?
    username == 'anonymous'
  end

  # Enable saving users without a password if they have another authenication scheme
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

 	def self.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	def self.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

  def under_13?
    birthdate > 13.years.ago
  end

  def age
    if birthdate
      now = Date.current
      now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
    end
  end

  def name
    read_attribute(:name) || username
  end

	protected

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
    end

    def add_and_push_message(followed_user)

      message = UserFollowed.new

      message.follower_id = self.id
      message.user_id = followed_user.id
      message.read_at = nil

      message.save

      followed_user.instances.each do |instance|
        next unless instance.push_token.present?

        instance.push alert:"#{username} followed you", badge:messages.count, sound:true, other: {type: message.type,
                                                                          created_at: message.created_at,
                                                                          read_at: message.read_at,
                                                                          follower_id: message.follower_id }
      end
    end

  private

    def over_13
      errors.add(:birthdate, "must be over 13 years ago") if birthdate.present? && under_13?
    end

end
