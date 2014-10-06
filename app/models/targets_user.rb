class TargetsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :target
end
