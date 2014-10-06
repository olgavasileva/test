class GroupsTarget < ActiveRecord::Base
  belongs_to :group
  belongs_to :target
end
