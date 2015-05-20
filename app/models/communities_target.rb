class CommunitiesTarget < ActiveRecord::Base
  belongs_to :consumer_target, foreign_key: :target_id
  belongs_to :community
end
