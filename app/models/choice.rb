class Choice < ActiveRecord::Base
	belongs_to :question
	has_many :responses, dependent: :destroy

	validates :question, presence: true
  validates :title, presence: true
  validates :rotate, inclusion:{in:[true,false]}
end
