require 'choice_result_cache'
require 'question_choice_orderer'

class Question < ActiveRecord::Base
  STATES ||= %w(preview targeting active suspended survey_only)
  KINDS ||= %w(public targeted)

	belongs_to :user, class_name: "Respondent"
	belongs_to :category
  belongs_to :target
  belongs_to :background_image, class_name: "QuestionImage"
  belongs_to :trend

	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :sharings, dependent: :destroy
	has_many :responses, dependent: :destroy
  has_many :respondents, through: :responses, source: :user
  has_many :users,  through: :responses
	has_many :feed_items, dependent: :destroy
  has_many :skip_users, -> {where "feed_items_v2.hidden" => true, "feed_items_v2.hidden_reason" => 'skipped'}, through: :feed_items, source: :user
  has_many :choices
  has_many :question_reports
  has_many :group_targets
  has_many :target_groups, through: :group_targets, source: :group
  has_many :follower_targets
  has_many :target_followers, through: :follower_targets, source: :follower
  has_many :comments, as: :commentable
  has_many :response_comments, through: :responses, source: :comment
  has_many :inappropriate_flags, dependent: :destroy
  has_many :response_matchers, dependent: :destroy
  has_many :communities, through: :target, source: :communities

  acts_as_taggable_on :tags

  scope :not_suspended, -> { where.not state: 'suspended' }
	scope :active, -> { where state:"active" }
  scope :suspended, -> { where state:"suspended" }
  scope :publik, -> { where kind:"public" }
  scope :currently_targetable, -> { where currently_targetable:true }
  scope :inappropriate, -> { includes(:inappropriate_flags).having("count(inappropriate_flags.id) > 0") }

  scope :latest, -> { order("feed_items_v2.published_at DESC, feed_items_v2.id DESC") }
  scope :by_relevance, -> { order("feed_items_v2.relevance DESC, feed_items_v2.published_at DESC, feed_items_v2.id DESC") }
  scope :trending, -> { joins(:trend).order("trends.rate * trending_multiplier DESC, feed_items_v2.published_at DESC") }
  scope :targeted, -> { where("feed_items_v2.targeted = ?", true) }
  scope :myfeed, -> { where("feed_items_v2.why" => %w(targeted leader follower group community)) }

	default kind: "public"
  default trending_multiplier: 1

	validates :user, presence: true
	validates :title, presence: true, length: { maximum: 250 }
	validates :state, presence: true, inclusion: {in: STATES}
	validates :kind, inclusion: {in: KINDS}
  validates :background_image, presence:true
  validates :trending_multiplier, numericality: { only_integer: true, allow_nil: true }
  validates :trend, presence: true, uniqueness: true
  validate :category_exists?, if: :category_id?

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image

  delegate :rate, to: :trend, prefix: true, allow_nil: true

  default share_count: 0
  default view_count: 1   # Creator has "viewed" it
  default :trend do |q|
    q.build_trend
  end

  default :uuid do |question|
    "Q"+UUID.new.generate.gsub(/-/, '')
  end

  before_create :add_creation_score
  after_validation :force_rotate, on: :create

  # Uses squeel gem to make the query easier to write and read
  def self.search_for search_text
    # Outer join to include questions without any choices
    # Group by question id to just get unique questions
    joins{choices.outer}.where{(title =~ "%#{search_text}%") | (choices.title =~ "%#{search_text}%")}.group{questions.id}
  end

  # Returns the number of individual responses - override if multiple choices are allowed
  def choice_count
    responses.count
  end

  # +1 if asked by one of the recipient's followers
  # +1 if asked by one of the recipient's leaders
  # +1 for each of the recipient's followers who answered this question
  # +1 for each of the recipient's leaders who answered this question
  def relevance_to recipient
    follower_ids = recipient.followers.pluck(:id)
    leader_ids = recipient.leaders.pluck(:id)

    (follower_ids.include?(user.id) ? 1 : 0) +
    (leader_ids.include?(user.id) ? 1 : 0) +
    responses.joins(:user).where('users.id' => follower_ids + leader_ids).count
  end

  def answered! user
    trend.event!
    FeedItem.question_answered! self, user
  end

  def apply_target! target
    transaction do
      update_attribute :target, target
      target.apply_to_question self
    end
  end

  def suspend!
    transaction do
      update_attribute :state, "suspended"
      FeedItem.question_suspended! self
    end
  end

	def viewed!
		update_attribute :view_count, (view_count.to_i + 1)
		DailyAnalytic.increment! :views, self.user
	end

	def started!
		update_attribute :start_count, (start_count.to_i + 1)
		DailyAnalytic.increment! :starts, self.user
	end

  def active?
		state == "active"
	end

  def suspended?
    state == "suspended"
  end

	def preview?
		state == "preview"
	end

	def targeting?
		state == "targeting"
	end

  def survey_only?
    state == 'survey_only'
  end

  def public?
    kind == 'public'
  end

	def activate!
		self.state = "active"
		self.save!
	end

	def included_by?(pack)
		self.inclusions.find_by(pack_id: pack.id)
	end

	def response_count
		responses.count
	end

  # TODO Calculate targeted reach based on actual views of the targeted question
  def targeted_reach
    view_count.to_i - viral_reach
  end

  def viral_reach
    [0, view_count.to_i - potential_targeted_reach.to_i].max
  end

  def potential_targeted_reach
    feed_items.where.not(why: :public).count
  end

	def comment_count
		comments.count + response_comments.count
	end


	def skip_count
    FeedItem.skipped.where(question_id: self).count
	end

  def add_and_push_message recipient

    message = QuestionTargeted.new

    message.user = recipient
    message.question = self

    user_name = anonymous? ? "Someone" : user.username
    message.body = "#{user_name} has a question for you"

    message.save!

    recipient.instances.where.not(push_token: nil).each do |instance|

      instance.push alert: message.body,
                    badge: recipient.messages.count,
                    sound: true,
                    other: {  type: message.type,
                              created_at: message.created_at,
                              read_at: message.read_at,
                              question_id: message.question_id,
                              body: message.body }
    end
  end

  def user_answered?(user)
    users.include?(user)
  end

  def csv_columns
    [title]
  end

  def notifiable?
    !notifying?
  end

  def choice_result_cache
    @choice_result_cache ||= ChoiceResultCache.new(self)
  end

  def ordered_choices_for(reader=nil)
    QuestionChoiceOrderer.new(self, reader)
  end

  private

    def add_creation_score
      self.score ||= 0
      self.score += comments.present? ? 1.5 : 1.0
    end

    def force_rotate
      self.rotate = true
    end

    def category_exists?
      unless Category.where(id: category_id).exists?
        errors.add(:base, 'Selected category does not exists')
      end
    end
end
