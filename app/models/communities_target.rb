class CommunitiesTarget < ActiveRecord::Base
  belongs_to :target
  belongs_to :community
end
