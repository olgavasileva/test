class ContestResponseVote < ActiveRecord::Base
  belongs_to :contest
  belongs_to :response
end
