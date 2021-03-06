class Category < ActiveRecord::Base
	has_many :questions, dependent: :destroy

	validates :name, presence: true, uniqueness: true

  mount_uploader :icon, IconUploader
end
