class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_users, through: :relationships, source: :followed
	has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
	has_many :followers, through: :reverse_relationships, source: :follower
	has_many :ownerships, dependent: :destroy
	has_many :devices, through: :ownerships
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

	before_save { self.email = email.downcase }
	before_save { self.username = username.downcase }
	before_create :create_remember_token
	
	VALID_USERNAME_REGEX = /\A[a-z0-9\-_]+\z/i
	validates :username, presence: true, 
						format: { with: VALID_USERNAME_REGEX },
						length: { maximum: 50 }, 
						uniqueness: { case_sensitive: false }
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
 	validates :email, 	presence: true, 
 						format: { with: VALID_EMAIL_REGEX }, 
 						uniqueness: { case_sensitive: false }
 	has_secure_password
 	validates :password, length: { minimum: 8 }

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

	def own!(device)
		self.ownerships.create!(device_id: device.id)
	end

	def disown!(device)
		self.ownerships.find_by(device_id: device.id).destroy!
	end

	def owner_of?(device)
		self.ownerships.find_by(device_id: device.id)
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

	def answered_questions
		Question.answered_by_user(self)
	end

	def as_json(options={})
  	super(:only => [:id, :username, :name])
	end

	def to_json(options={})
		super(:only => [:id, :username, :name])
	end

	private

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
		end
end