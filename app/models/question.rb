class Question < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :inclusions, dependent: :destroy
	has_many :packs, through: :inclusions
	has_many :comments, dependent: :destroy
	has_many :sharings, dependent: :destroy

	validates :user, presence: true
	validates :category, presence: true
	validates :title, presence: true

  mount_uploader :image, CategoryImageUploader
  mount_uploader :info_image, ImageUploader

	def included_by?(pack)
		self.inclusions.find_by(pack_id: pack.id)
	end

	def self.answered_by_user(user)
		answered_question_ids = "SELECT question_id FROM answers WHERE user_id = :user_id"
		where("id IN (#{answered_question_ids})", user_id: user)
	end

	def as_json(options={})
		super(:include => [:category, :choices, :user => {:only => [:id, :username, :name]}], :only => [:id, :created_at, :title, :info, :image_url, :question_type, :min_value, :max_value, :interval, :units, :updated_at, :hidden])
	end
end
