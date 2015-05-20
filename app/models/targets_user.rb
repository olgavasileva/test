class TargetsUser < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  belongs_to :consumer_target, foreign_key: :target_id
end
