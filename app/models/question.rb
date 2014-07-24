class Question < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :sharings, dependent: :destroy
	has_many :responses

	validates :user, presence: true
	validates :category, presence: true
	validates :title, presence: true

  mount_uploader :image, QuestionImageUploader
  mount_uploader :info_image, InfoImageUploader

	def included_by?(pack)
		self.inclusions.find_by(pack_id: pack.id)
	end

	def response_count
		responses.count
	end

	def comment_count
		responses.where("comment is not ?", nil).count
	end
end
