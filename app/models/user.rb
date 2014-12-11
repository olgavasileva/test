class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable,
         authentication_keys:[:login], reset_password_keys:[:login]

  belongs_to :avatar, class_name: "UserAvatar", foreign_key: :user_avatar_id

  has_many :responses, dependent: :destroy
  has_many :order_responses, class_name: "OrderResponse"
  has_many :choice_responses, class_name: "ChoiceResponse"
  has_many :multiple_choice_responses, class_name: "MultipleChoiceResponse"
  has_many :feed_items, dependent: :destroy
  has_many :feed_questions, -> { where(feed_items_v2:{hidden: false}).where("feed_items_v2.published_at <= ?", Time.current).order("feed_items_v2.published_at DESC, feed_items_v2.id DESC") }, through: :feed_items, source: :question
  has_many :answered_questions, through: :responses, source: :question
  has_many :inappropriate_flags, dependent: :destroy
  has_many :scenes, dependent: :destroy

  has_many :groups, dependent: :destroy
  has_many :group_members, through: :groups, source: :user
  has_many :group_memberships, class_name: 'GroupMember'
  has_many :membership_groups, through: :group_memberships, source: :group

  has_many :communities, dependent: :destroy
  has_many :community_members, through: :communities, source: :user
  has_many :community_memberships, class_name: 'CommunityMember'
  has_many :membership_communities, through: :community_memberships, source: :community

  has_many :targets, dependent: :destroy
  has_many :enterprise_targets, dependent: :destroy

  has_many :targets_users
  has_many :following_targets, through: :targets_users, source: :target

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

	has_many :packs, dependent: :destroy
	has_many :sharings, foreign_key: "sender_id", dependent: :destroy
	has_many :reverse_sharings, foreign_key: "receiver_id", class_name: "Sharing", dependent: :destroy

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

  # Comments made by other users about this user's questions and responses
  def comments_on_questions_and_responses
    Comment.where id:(comments_on_its_questions.pluck("comments.id") + comments_on_its_responses.pluck("comments.id"))
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

  def wants_question? question
    feed_items.where(question_id:question).empty?
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

  def name
    read_attribute(:name) || username
  end

  def under_13?
    birthdate > 13.years.ago
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
