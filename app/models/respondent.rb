class Respondent < ActiveRecord::Base
  self.table_name = 'users'

  has_many :responses, dependent: :destroy, foreign_key: :user_id
  has_many :order_responses, class_name: "OrderResponse", foreign_key: :user_id
  has_many :choice_responses, class_name: "ChoiceResponse", foreign_key: :user_id
  has_many :multiple_choice_responses, class_name: "MultipleChoiceResponse", foreign_key: :user_id
  has_many :feed_items, dependent: :destroy, foreign_key: :user_id
  has_many :feed_questions, -> { where(feed_items_v2:{hidden: false}).where("feed_items_v2.published_at <= ?", Time.current).active }, through: :feed_items, source: :question, foreign_key: :user_id
  has_many :answered_questions, through: :responses, source: :question, foreign_key: :user_id
  has_many :inappropriate_flags, dependent: :destroy, foreign_key: :user_id
  has_many :scenes, dependent: :destroy, foreign_key: :user_id

  has_many :groups, dependent: :destroy, foreign_key: :user_id
  has_many :group_members, through: :groups, source: :user
  has_many :group_memberships, class_name: 'GroupMember', foreign_key: :user_id
  has_many :membership_groups, through: :group_memberships, source: :group

  has_many :communities, dependent: :destroy, foreign_key: :user_id
  has_many :community_members, through: :communities, source: :user
  has_many :community_memberships, class_name: 'CommunityMember', foreign_key: :user_id
  has_many :membership_communities, through: :community_memberships, source: :community

  has_many :targets, dependent: :destroy, foreign_key: :user_id
  has_many :enterprise_targets, dependent: :destroy, foreign_key: :user_id

  has_many :targets_users, foreign_key: :user_id
  has_many :following_targets, through: :targets_users, source: :target

  has_many :messages, dependent: :destroy, foreign_key: :user_id

  has_many :followership_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :leaders, through: :followership_relationships, source: :leader

  has_many :leadership_relationships, class_name: "Relationship", foreign_key: "leader_id", dependent: :destroy
  has_many :followers, through: :leadership_relationships, source: :follower

  has_many :instances, dependent: :destroy, foreign_key: :user_id

  has_many :devices, through: :instances

  # Questions asked by this user
  has_many :questions, dependent: :destroy, foreign_key: :user_id

  # Responses to this user's questions
  has_many :responses_to_questions, through: :questions, source: :responses

  has_many :packs, dependent: :destroy, foreign_key: :user_id
  has_many :sharings, foreign_key: "sender_id", dependent: :destroy
  has_many :reverse_sharings, foreign_key: "receiver_id", class_name: "Sharing", dependent: :destroy

  # Comments made by this user
  has_many :comments, dependent: :destroy, foreign_key: :user_id
  has_many :question_comments, -> {where commentable_type:"Question"}, class_name: "Comment", foreign_key: :user_id
  has_many :response_comments, -> {where commentable_type:"Response"}, class_name: "Comment", foreign_key: :user_id
  has_many :comment_comments, -> {where commentable_type:"Comment"}, class_name: "Comment", foreign_key: :user_id

  # Comments made by other users about this user's responses or questions
  has_many :comments_on_its_responses, through: :responses_to_questions, source: :comment
  has_many :comments_on_its_questions, through: :questions, source: :comments

  has_many :segments, dependent: :destroy, foreign_key: :user_id

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

  # Comments made by other users about this user's questions and responses
  def comments_on_questions_and_responses
    Comment.where id:(comments_on_its_questions.pluck("comments.id") + comments_on_its_responses.pluck("comments.id"))
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

  # Clear and then add all the active public questions to the feed
  def reset_feed!
    transaction do
      feed_items.destroy_all
      Question.active.publik.order("created_at ASC").each do |q|
        FeedItem.create! user:self, question:q, published_at:q.created_at, why: "public"
      end
    end
  end

  def under_13?
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def age
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def name
    raise NotImplementedError.new("You must implement this method in a subclass")
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