class Question < ActiveRecord::Base
  STATES ||= %w(preview targeting active suspended survey_only)
  KINDS ||= %w(public targeted)

	belongs_to :user
	belongs_to :category
  belongs_to :target
  belongs_to :background_image, class_name: "QuestionImage"

	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :sharings, dependent: :destroy
	has_many :responses, dependent: :destroy
  has_many :response_users, through: :responses, source: :user
  has_many :users,  through: :responses
	has_many :feed_items, dependent: :destroy
  has_many :skip_users, -> {where hidden: true, hidden_reason: 'skipped'}, through: :feed_items, source: :user
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

	scope :active, -> { where state:"active" }
  scope :suspended, -> { where state:"suspended" }
  scope :publik, -> { where kind:"public" }
  scope :currently_targetable, -> { where currently_targetable:true }
  scope :inappropriate, -> { includes(:inappropriate_flags).having("count(inappropriate_flags.id) > 0") }

  scope :latest, -> { order("feed_items_v2.published_at DESC, feed_items_v2.id DESC") }
  scope :by_relevance, -> { order("feed_items_v2.relevance DESC, feed_items_v2.published_at DESC, feed_items_v2.id DESC") }
  scope :trending, -> { order("questions.trending_index DESC, feed_items_v2.published_at DESC") }
  scope :targeted, -> { where("feed_items_v2.targeted = ?", true) }
  scope :myfeed, -> { where("feed_items_v2.why" => %w(targeted leader follower)) }

	default kind: "public"
  default trending_index: 0
  default trending_multiplier: 1

	validates :user, presence: true
	validates :category, presence: true
	validates :title, presence: true, length: { maximum: 250 }
	validates :state, presence: true, inclusion: {in: STATES}
	validates :kind, inclusion: {in: KINDS}
  validates :background_image, presence:true
  validates :trending_index, numericality: { only_integer: true, allow_nil: true }
  validates :trending_multiplier, numericality: { only_integer: true, allow_nil: true }

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image

  default share_count: 0
  default view_count: 1   # Creator has "viewed" it

  default :uuid do |question|
    "Q"+UUID.new.generate.gsub(/-/, '')
  end

  before_create :add_creation_score

  # Uses squeel gem to make the query easier to write and read
  def self.search_for search_text
    # Outer join to include questions without any choices
    # Group by question id to just get unique questions
    joins{choices.outer}.where{(title =~ "%#{search_text}%") | (choices.title =~ "%#{search_text}%")}.group{questions.id}
  end

  # +1 if asked by one of the recipient's followers
  # +1 if asked by one of the recipient's leaders
  # +1 for each of the recipient's followers who answered this question
  # +1 for each of the recipient's leaders who answered this question
  def relevance_to recipient
    recipient.followers.where(id:user).count +
    recipient.leaders.where(id:user).count +
    responses.joins(:user).where('users.id' => recipient.followers.pluck(:id)).count +
    responses.joins(:user).where('users.id' => recipient.leaders.pluck(:id)).count
  end

  def trending!
    # TODO use IIR algorithm here and call this whenever needed
    update_attribute :trending_index, (trending_index + trending_multiplier)
  end

  def answered! user
    trending!
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

	def comment_count
		comments.count + response_comments.count
	end


	def skip_count
    FeedItem.skipped.where(question_id: self).count
	end

  private

  def add_creation_score
    self.score ||= 0
    self.score += comments.present? ? 1.5 : 1.0
  end
end
