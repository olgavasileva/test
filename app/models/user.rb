class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys:[:login], reset_password_keys:[:login]

  has_many :responses, dependent: :destroy
  has_many :answered_questions, through: :responses, source: :question
  has_many :messages, dependent: :destroy
  # Allow user to log in using username OR email in the 'login' text area
	# https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
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

	has_many :microposts, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed
	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower
	has_many :instances, dependent: :destroy
	has_many :authentications, dependent: :destroy
	has_many :devices, through: :instances
	has_many :questions, dependent: :destroy
	has_many :answers, dependent: :destroy
	has_many :packs, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :friendships, foreign_key: "user_id", dependent: :destroy
	has_many :friends, through: :friendships, source: :friend
	has_many :reverse_friendships, foreign_key: "friend_id", class_name: "Friendship", dependent: :destroy
	has_many :reverse_friends, through: :reverse_friendships, source: :user
	has_many :sharings, foreign_key: "sender_id", dependent: :destroy
	has_many :reverse_sharings, foreign_key: "receiver_id", class_name: "Sharing", dependent: :destroy

	before_create :create_remember_token

	VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
	validates :username, presence: true,
						format: { with: VALID_USERNAME_REGEX },
						length: { maximum: 50 },
						uniqueness: { case_sensitive: false }
	validates :name, presence: true, length: { maximum: 50 }
	validates :terms_and_conditions, acceptance: true

  # Enable saving users without a password if they have another authenication scheme
  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

 	def User.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def feed
		Micropost.from_users_followed_by(self)
	end

	def following?(other_user)
		self.relationships.find_by(followed_id: other_user.id)
	end

	def follow!(other_user)
		self.relationships.create!(followed_id: other_user.id)
	end

	def unfollow!(other_user)
		self.relationships.find_by(followed_id: other_user.id).destroy!
	end

	def friends_with?(other_user)
		self.friendships.find_by(friend_id: other_user.id)
	end

	def friend!(other_user)
		self.friendships.create!(friend_id: other_user.id, status: 'accepted')
	end

	def unfriend!(other_user)
		self.friendships.find_by(friend_id: other_user.id).destroy!
	end

  def number_of_answered_questions
    return Response.where(user_id:id).count
  end
  def number_of_asked_questions
    return Question.where(user_id:id).count
  end

  def number_of_comments_left
    return self.responses.where("comment is not ?", nil).count
  end


	def unanswered_questions
    answered_question_ids = Response.where(user_id:id).pluck(:question_id)
    answered_question_ids.present? ? Question.where("id NOT IN (?)", answered_question_ids) : Question.all
	end

	private

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
		end
end
