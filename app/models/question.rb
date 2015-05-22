require 'choice_result_cache'
require 'question_choice_orderer'

class Question < ActiveRecord::Base
  STATES ||= %w(preview targeting active suspended survey_only)
  KINDS ||= %w(public targeted)

	belongs_to :user, class_name: "Respondent"
	belongs_to :category
  belongs_to :target      # This is the target criteria that the user specified when the question was created
  belongs_to :background_image, class_name: "QuestionImage"
  belongs_to :trend
  belongs_to :consumer_target, foreign_key: :target_id

  # Attribute that allows questions to be added to surveys
  attr_accessor :survey_id, :survey_position
  has_one :questions_survey, dependent: :destroy
  has_one :survey, through: :questions_survey

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
  has_many :communities, through: :consumer_target, source: :communities

  # Respondents to whom question was targeted
  has_many :question_targets
  has_many :targeted_respondents, through: :question_targets, source: :respondents

  # Respondents who took an action with this question
  has_many :question_actions
  has_many :question_action_skips
  # Respondents who skipped this question
  has_many :skippers, through: :question_skip_actions, source: :respondets
  has_many :question_action_responses
  # Respondents who answered this question (different way to the same set as :respondents, above)
  has_many :responders, through: :question_action_responses, source: :respondents

  acts_as_taggable_on :tags

  scope :not_suspended, -> { where.not state: 'suspended' }
	scope :active, -> { where state:"active" }
  scope :suspended, -> { where state:"suspended" }
  scope :publik, -> { where kind:"public" }
  scope :targeted, -> { where kind:"targeted" }
  scope :currently_targetable, -> { where currently_targetable:true }
  scope :inappropriate, -> { includes(:inappropriate_flags).having("count(inappropriate_flags.id) > 0") }

  scope :latest, -> { order("created_at DESC, id DESC") }
  scope :by_relevance, -> { order("question_targets.relevance DESC, question_targets.created_at DESC, question_targets.id DESC") }
  scope :trending, -> { joins(:trend).order("trends.rate * trending_multiplier DESC, questions.created_at DESC") }
  scope :trending_on_recent_response_count, -> { order("recent_responses_count DESC, questions.created_at DESC") }

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
  validate :can_add_survey?, if: 'survey_id.present?'

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

  after_validation :force_rotate, on: :create
  before_create :add_creation_score
  after_create :add_to_survey, if: 'survey_id.present?'

  # Uses squeel gem to make the query easier to write and read
  # - Outer join to include questions without the association
  # - Group by question id to get unique questions
  #
  def self.search_for search_text
    search_text = search_text.downcase

    joins{choices.outer}.joins{tags.outer}
      .where {
        (lower(title) =~ "%#{search_text}%") |
        (lower(choices.title) =~ "%#{search_text}%") |
        (lower(tags.name) =~ "%#{search_text}%")
      }
      .group{questions.id}
  end

  # Returns the number of individual responses - override if multiple choices are allowed
  def choice_count
    responses.count
  end

  # +1 if asked by one of the recipient's followers
  # +1 if asked by one of the recipient's leaders
  # +1 for each of the recipient's followers who answered this question
  # +1 for each of the recipient's leaders who answered this question
  # TODO: Caculate this for each question in the background periodically
  def relevance_to recipient
    follower_ids = recipient.followers.pluck(:id)
    leader_ids = recipient.leaders.pluck(:id)

    (follower_ids.include?(user.id) ? 1 : 0) +
    (leader_ids.include?(user.id) ? 1 : 0) +
    responses.joins(:user).where('users.id' => follower_ids + leader_ids).count
  end

  def answered! respondent
    QuestionActionResponse.create! question: self, respondent: respondent
    trend.event!
  end

  def suspend!
    transaction do
      update_attribute :state, "suspended"
    end
  end

	def viewed!
		update_attribute :view_count, (view_count.to_i + 1)
		DailyAnalytic.increment! :views, self.user
	end

  def skipped! respondent
    QuestionActionSkip.create! question: self, respondent: respondent
    decrement! :score, 0.25
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

  def targeting! target
    update_attributes target: target, state: :targeting
  end

	def activate!
    update_attribute :state, :active
	end

	def included_by?(pack)
		self.inclusions.find_by(pack_id: pack.id)
	end

	def response_count
		responses.count
	end

  # TODO Calculate targeted reach based on actual views of the targeted question
  def targeted_reach
    response_count = respondents.count

    response_count > 0 ? (view_count.to_i * respondents.where(type:'User').count.to_f / response_count).to_i : 0
  end

  def viral_reach
    view_count.to_i - targeted_reach
  end

	def comment_count
		comments.count + response_comments.count
	end


	def skip_count
    question_action_skips.count
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

  # We are using recent_responses_count to tell us how many recent responses have been made
  # lookback_days is the number of days we will consider
  def self.refresh_recent_responses_count! lookback_days = 14
    # Count recent responses
    count_info = Response.where{created_at >= Time.current - lookback_days.days}.group(:question_id).count
    ids = count_info.keys
    counts = count_info.values

    # Clear all question response counters without recent responses
    Question.where.not(id: ids).update_all(recent_responses_count: 0)

    # Update all response counters with the new count
    count_info.each do |id, count|
      Question.where(id: id).update_all(recent_responses_count: count)
    end
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

    def can_add_survey?
      if survey = Survey.find_by(id: survey_id)
        unless user_id == survey.user_id
          errors.add(:survey_id, "is unauthorized for this user")
        end
      else
        errors.add(:base, "Survey does not exist")
      end
    end

    def add_to_survey
      create_questions_survey!(survey_id: survey_id, position: survey_position)
    end
end
