class ContestResponseVote < ActiveRecord::Base
  belongs_to :contest
  belongs_to :response

  default vote_count: 0

  def increment_vote_count!
    update_attribute :vote_count, vote_count.to_i + 1
  end
end
