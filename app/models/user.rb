class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys:[:login], reset_password_keys:[:login]

  has_many :responses, dependent: :destroy
  has_many :feed_items, dependent: :destroy
  has_many :feed_questions, through: :feed_items, source: :question
  has_many :answered_questions, through: :responses, source: :question
  has_many :skipped_items, dependent: :destroy
  has_many :skipped_questions, through: :skipped_items, source: :question

  has_many :groups, dependent: :destroy
  has_many :group_members, through: :groups, source: :user

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

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
	attr_accessor :login

  has_many :followership_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :leaders, through: :followership_relationships, source: :leader

  has_many :leadership_relationships, class_name: "Relationship", foreign_key: "leader_id", dependent: :destroy
  has_many :followers, through: :leadership_relationships, source: :follower

  has_many :instances, dependent: :destroy
	has_many :authentications, dependent: :destroy
	has_many :devices, through: :instances
	has_many :questions, dependent: :destroy
	has_many :packs, dependent: :destroy
	has_many :sharings, foreign_key: "sender_id", dependent: :destroy
	has_many :reverse_sharings, foreign_key: "receiver_id", class_name: "Sharing", dependent: :destroy
  has_many :liked_comments
  has_many :liked_comment_responses, through: :liked_comments, source: :response
  has_many :responses_with_comments, -> {where "responses.comment IS NOT NULL AND responses.comment != ''"}, class_name: "Response"

	before_create :create_remember_token

	VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
	validates :username, presence: true,
						format: { with: VALID_USERNAME_REGEX },
						length: { maximum: 50 },
						uniqueness: { case_sensitive: false }
	validates :name, length: { maximum: 50 }
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

	def following? leader
		self.followership_relationships.where(leader_id: leader.id).present?
	end

	def follow! leader
		self.leaders << leader
	end

	def unfollow! leader
    self.leaders.where(id:leader.id).destroy!
	end

	def unanswered_questions
    answered_question_ids = Response.where(user_id:id).pluck(:question_id)
    answered_question_ids.present? ? Question.where("id NOT IN (?)", answered_question_ids) : Question.all
	end

  def wants_question? question
    feed_items.where(question_id:question).blank? && responses.where(question_id:question).blank? && skipped_items.where(question_id:question).blank?
  end

  # Add more public questions to the feed
  # Do not add questions that have been skipped or answered by this user
  # Do not add questions that are already in this user's feed
  def feed_more_questions num_to_add
    all_public_questions = Question.where(kind: 'public')

    # Do it the inefficient way if we don't have too many records since grabbing random items from a small sample is prone to too many misses
    new_questions = if all_public_questions.count < 1000 &&  skipped_items.count + responses.count + feed_items.count < 1000
      candidate_ids = all_public_questions.where.not(id:skipped_questions.pluck("questions.id") + answered_questions.pluck("questions.id") + feed_questions.pluck("questions.id"))
      Question.where id:candidate_ids.sample(num_to_add)
    else
      new_questions = []
      num_candidates = candidates.count
      while new_questions.count < num_to_add
        candidate = all_public_questions.order(:id).offset(rand(num_candidates)).limit(1)
        new_questions << candidate if wants_question?(candidate)
      end
      new_questions
    end

    self.feed_questions += new_questions
  end

	private

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
		end
end
