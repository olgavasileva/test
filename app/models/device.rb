class Device < ActiveRecord::Base
	has_many :ownerships, dependent: :destroy
	has_many :users, through: :ownerships
	validates :udid, presence: true
	validates :device_type, presence: true
	validates :os_version, presence: true

	def owned_by?(user)
		self.ownerships.find_by(user_id: user.id)
	end

	def as_json(options={})
  	super(:only => [:id, :udid, :device_type, :os_version])
	end
end
