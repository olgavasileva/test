class Question < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :sharings, dependent: :destroy
	has_many :responses
	has_many :responses_with_comments, -> { where "comment != ''" }, class_name: "Response"
	has_many :feed_items, dependent: :destroy
	has_many :skips, class_name:"SkippedItem", dependent: :destroy

	scope :active, -> { where state:"active" }

	default kind: "public"

	validates :user, presence: true
	validates :category, presence: true
	validates :title, presence: true, length: { maximum: 250 }
	validates :state, presence: true, inclusion: {in: %w(preview targeting active)}
	validates :kind, inclusion: {in: %w(public targeted)}

	def active?
		state == "active"
	end

	def preview?
		state == "preview"
	end

	def targeting?
		state == "targeting"
	end

	def activate!
		self.state = "active"
		self.save!
	end

  def web_image_url
    # TODO: show a representation of the set of responses for some question types
    "fallback/choice1.png"  # For now, just show something
  end

	def included_by?(pack)
		self.inclusions.find_by(pack_id: pack.id)
	end

	def response_count
		responses.count
	end

	def comment_count
		responses_with_comments.count
	end

	def share_count
		0
	end

	def skip_count
		skips.count
	end
end
