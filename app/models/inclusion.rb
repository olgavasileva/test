class Inclusion < ActiveRecord::Base
	belongs_to :pack
	belongs_to :question
	validates :pack_id, presence: true
	validates :question_id, presence: true
end
