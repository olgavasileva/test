class Question < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :sharings, dependent: :destroy
	has_many :responses
	has_many :responses_with_comments, -> { where "comment != ''" }, class_name: "Response"

	validates :user, presence: true
	validates :category, presence: true
	validates :title, presence: true

  mount_uploader :image, QuestionImageUploader
  mount_uploader :info_image, InfoImageUploader

  before_save :save_image_from_index

  #
  # Image indexes
  #

  CANNED_IMAGE_PATHS ||= %w(question_bg/bluegrunge.png question_bg/bluetriangle.png question_bg/bluetriangular.png question_bg/bluewall.png question_bg/greengrunge.png question_bg/greentriangle.png question_bg/greentriangular.png question_bg/greenwall.png question_bg/redgrunge.png question_bg/redtriangle.png question_bg/redtriangular.png question_bg/redwall.png question_bg/yellowgrunge.png question_bg/yellowtriangle.png question_bg/yellowtriangular.png question_bg/yellowwall.png)

  attr_accessor :image_index

  def image_index
    @image_index
  end

  def image_index= index
    @image_index = index
  end



  def web_image_url
    if image.present?
	      image.web.url
    else
      # TODO: show a representation of the set of responses
      "fallback/choice1.png"
    end
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
		0
	end

  protected
    def save_image_from_index
      self.image = open File.join(Rails.root, "app/assets/images", CANNED_IMAGE_PATHS[@image_index.to_i]) if @image_index
      true
    end
end
