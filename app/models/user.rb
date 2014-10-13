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
  has_many :inappropriate_flags, dependent: :destroy

  has_many :groups, dependent: :destroy
  has_many :group_members, through: :groups, source: :user
  has_many :group_memberships, class_name: 'GroupMember'
  has_many :membership_groups, through: :group_memberships, source: :group

  has_many :communities, dependent: :destroy
  has_many :community_members, through: :communities, source: :user
  has_many :community_memberships, class_name: 'CommunityMember'
  has_many :membership_communities, through: :community_memberships, source: :community
  has_many :targets, dependent: :destroy

  has_many :messages, dependent: :destroy

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

  # Questions asked by this user
	has_many :questions, dependent: :destroy

  # Responses to this user's questions
  has_many :responses_to_questions, through: :questions, source: :responses

  has_many :questions_skips, through: :questions, source: :skips
	has_many :packs, dependent: :destroy
	has_many :sharings, foreign_key: "sender_id", dependent: :destroy
	has_many :reverse_sharings, foreign_key: "receiver_id", class_name: "Sharing", dependent: :destroy
  has_many :liked_comments
  has_many :liked_comment_responses, through: :liked_comments, source: :response

  # Comments made by this user
  has_many :comments, dependent: :destroy
  has_many :question_comments, -> {where commentable_type:"Question"}, class_name: "Comment"
  has_many :response_comments, -> {where commentable_type:"Response"}, class_name: "Comment"
  has_many :comment_comments, -> {where commentable_type:"Comment"}, class_name: "Comment"

  # Comments made by other users about this user's responses or questions
  has_many :comments_on_its_responses, through: :responses_to_questions, source: :comment
  has_many :comments_on_its_questions, through: :questions, source: :comments

  has_many :segments, dependent: :destroy

	before_create :create_remember_token

	VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
	validates :username, presence: true,
						format: { with: VALID_USERNAME_REGEX },
						length: { maximum: 50 },
						uniqueness: { case_sensitive: false }
	validates :name, length: { maximum: 50 }
	validates :terms_and_conditions, acceptance: true

  # Comments made by other users about this user's questions and responses
  def comments_on_questions_and_responses
    Comment.where id:(comments_on_its_questions.pluck("comments.id") + comments_on_its_responses.pluck("comments.id"))
  end

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

    count = self.leaders.count
		self.leaders << leader

    if self.leaders.count != count
      add_and_push_message leader
    end

	end

	def unfollow! leader
    self.leaders.where(id:leader.id).destroy!
	end

	def unanswered_questions
    answered_question_ids = Response.where(user_id:id).pluck(:question_id)
    answered_question_ids.present? ? Question.where("id NOT IN (?)", answered_question_ids) : Question.all
	end

  def wants_question? question
    feed_items.where(question_id:question).blank? && responses.where(question_id:question).blank? && skipped_items.where(question_id:question).blank? && questions.where(id:question).blank?
  end

  # Add more public questions to the feed
  # Do not add questions that have been skipped or answered by this user
  # Do not add questions that are already in this user's feed
  def feed_more_questions num_to_add
    all_public_questions = Question.active.currently_targetable.where(kind: 'public')

    # small_dataset = all_public_questions.count < 1000 &&  skipped_items.count + responses.count + feed_items.count < 1000
    small_dataset = true # TODO: for now, just use the easier unpotimized selection logic

    new_questions = if small_dataset
      # TODO: This is inefficient for very large datasets - optimize when needed
      candidate_ids = all_public_questions.where.not(id:skipped_questions.pluck("questions.id") + answered_questions.pluck("questions.id") + feed_questions.pluck("questions.id"))
      Question.where(id:candidate_ids.sample(num_to_add)).order("CASE WHEN questions.position IS NULL THEN 1 ELSE 0 END ASC").order("questions.position ASC").order("RAND()")
    else
      # Grabbing random items from a small sample is prone to too many misses, so only do this on a larger dataset
      new_questions = []
      num_candidates = all_public_questions.count
      while new_questions.count < num_to_add
        candidate = all_public_questions.order(:id).offset(rand(num_candidates)).limit(1)
        new_questions << candidate if wants_question?(candidate)
      end
      new_questions
    end

    self.feed_questions += new_questions
  end

  def read_all_messages
    messages.find_each { |m| m.update_attributes(read_at: Time.zone.now) }
  end

  def number_of_answered_questions
    return Response.where(user_id:id).count
  end

  def number_of_asked_questions
    return Question.where(user_id:id).count
  end

  def number_of_comments_left
    return self.comments.count
  end

  def number_of_followers
    return self.followers.count
  end

  def number_of_unread_messages
    return self.messages.where("read_at is ?", nil).count
  end

	protected

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
    end

    def add_and_push_message(followed_user)

      # if UserFollowed.where("follower_id = ? AND user_id = ?", self.id, followed_user.id).exists?
      #   message = UserFollowed.where("follower_id = ? AND user_id = ?", self.id, followed_user.id)
      # else
      #
      # end

      message = UserFollowed.new

      message.follower_id = self.id
      message.user_id = followed_user.id
      message.read_at = nil

      message.save

      followed_user.instances.each do |instance|
        next unless instance.push_token.present?

        instance.push alert:'Hello iPhone!', badge:0, sound:true, other: {type: message.type,
                                                                          created_at: message.created_at,
                                                                          read_at: message.read_at,
                                                                          follower_id: message.follower_id }
      end
    end

end
