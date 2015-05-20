class GroupsTarget < ActiveRecord::Base
  belongs_to :group
  belongs_to :consumer_target, foreign_key: :target_id
end
