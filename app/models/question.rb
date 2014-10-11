class Question < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
  belongs_to :target
  belongs_to :background_image

	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :sharings, dependent: :destroy
	has_many :responses, dependent: :destroy
  has_many :users,  through: :responses
	has_many :feed_items, dependent: :destroy
	has_many :skips, class_name:"SkippedItem", dependent: :destroy
  has_many :choices
  has_many :question_reports
  has_many :group_targets
  has_many :target_groups, through: :group_targets, source: :group
  has_many :follower_targets
  has_many :target_followers, through: :follower_targets, source: :follower
  has_many :comments, as: :commentable
  has_many :response_comments, through: :responses, source: :comment
  has_many :inappropriate_flags, dependent: :destroy

	scope :active, -> { where state:"active" }
  scope :suspended, -> { where state:"suspended" }
  scope :currently_targetable, -> { where currently_targetable:true }
  scope :inappropriate, -> { includes(:inappropriate_flags).having("count(inappropriate_flags.id) > 0") }

	default kind: "public"

	validates :user, presence: true
	validates :category, presence: true
	validates :title, presence: true, length: { maximum: 250 }
	validates :state, presence: true, inclusion: {in: %w(preview targeting active suspended)}
	validates :kind, inclusion: {in: %w(public targeted)}
  validates :background_image, presence:true

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image

  default :uuid do |question|
    "Q"+UUID.new.generate.gsub(/-/, '')
  end

  def apply_target! target
    self.update_attribute :target, target
    target.apply_to_question self
  end

  def suspend!
    update_attribute :state, "suspended"
    self.feed_items.destroy_all
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
		skips.count
	end
end
