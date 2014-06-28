class Inclusion < ActiveRecord::Base
	belongs_to :pack
	belongs_to :question
	validates :pack, presence: true
	validates :question, presence: true
end
