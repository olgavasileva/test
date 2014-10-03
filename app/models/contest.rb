class Contest < ActiveRecord::Base
  belongs_to :survey
  belongs_to :key_question, class_name:"Question"
  has_many :contest_response_votes, dependent: :destroy
end
