class Category < ActiveRecord::Base
	has_many :questions, dependent: :destroy

	validates :name, presence: true

  mount_uploader :image, CategoryImageUploader
  mount_uploader :icon, IconUploader
end
