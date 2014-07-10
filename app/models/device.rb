class Device < ActiveRecord::Base
	has_many :instances, dependent: :destroy
	has_many :users, through: :instances

	validates :device_vendor_identifier, presence: true
	validates :platform, presence: true
	validates :manufacturer, presence: true
	validates :model, presence: true
	validates :os_version, presence: true

	def owned_by? user
		self.instances.find_by(user_id: user.id).present?
	end
end
