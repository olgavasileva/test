class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :timeoutable, :trackable, :validatable,
         authentication_keys:[:login], reset_password_keys:[:login]

  has_many :responses, dependent: :destroy
  has_many :order_responses, class_name: "OrderResponse"
  has_many :choice_responses, class_name: "ChoiceResponse"
  has_many :multiple_choice_responses, class_name: "MultipleChoiceResponse"
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

  has_many :questions_skips, through: :questions, source: :skips
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
  validate :over_13

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

  def next_feed_questions(count = 10)
    # Potential questions are in active state.
    potential_questions = Question.active

    # Potential questions have not been in the user's feed.
    used_questions = feed_questions + answered_questions + skipped_questions
    potential_questions = potential_questions.where.not(id: used_questions)

    # Questions are in a specific order.
    questions = []

    # 1) special case
    questions += potential_questions.where(special: true).order_by_rand

    return questions.first(count) if questions.count >= count

    # 2) sponsored
    #   a) targeted
    #   b) untargeted

    # 3) directly targeted
    targets = TargetsUser.where(user_id: id).map(&:target)
    questions += potential_questions.where(target_id: targets)
                                    .where.not(id: questions)
                                    .order_by_rand

    return questions.first(count) if questions.count >= count

    # 4) staff
    staff = Group.find_by_name("Staff").try(:users) || []
    staff_questions = potential_questions.where(user_id: staff)

    #   a) targeted
    targets += Target.where(user_id: staff)
                     .where.any_of(all_users: true, all_followers: true, all_groups: true)
    targets += GroupsTarget.where(group_id: groups, user_id: staff).map(&:target)
    questions += staff_questions.where.not(id: questions).order_by_rand

    return questions.first(count) if questions.count >= count

    #   b) untargeted
    questions += staff_questions.where.not(id: questions, target_id: targets)
                                .order_by_rand

    return questions.first(count) if questions.count >= count

    # 5) followed users

    #   a) created & shared
    questions += potential_questions.where(user_id: leaders)
                                    .where.not(share_count: 0, id: questions)

    return questions.first(count) if questions.count >= count

    #   b) completed & shared
    responses = Response.where(user_id: leaders)
    questions += potential_questions.where(id: responses.map(&:question))
                                    .where.not(share_count: 0, id: questions)

    return questions.first(count) if questions.count >= count

    #   c) created & not shared
    questions += potential_questions.where(user_id: leaders)
                                    .where(share_count: [0, nil])
                                    .where.not(id: questions)

    return questions.first(count) if questions.count >= count

    # 6) top scoring
    questions += potential_questions.where.not(id: questions)
                                    .order('score DESC')

    return questions.first(count) if questions.count >= count

    # 7) random public
    questions += potential_questions.where.not(id: questions).order_by_rand.limit(10)

    questions.first(count)
  end

  def feed_more_questions(count)
    self.feed_questions += next_feed_questions(count)
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

        instance.push alert:"#{username} followed you", badge:messages.count, sound:true, other: {type: message.type,
                                                                          created_at: message.created_at,
                                                                          read_at: message.read_at,
                                                                          follower_id: message.follower_id }
      end
    end

  private

    def over_13
      return if birthdate.nil?

      errors.add(:birthdate, "can't be before 13 years ago") if under_13?
    end

end
