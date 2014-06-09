class Ownership < ActiveRecord::Base
	belongs_to :user
	belongs_to :device
	validates :user_id, presence: true
	validates :device_id, presence: true
	before_create :create_remember_token

	def as_json(options={})
  	super(:include => [:user => {:only => [:id, :username, :name]}], :only => [:id, :remember_token])
	end

	private

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
		end
end
