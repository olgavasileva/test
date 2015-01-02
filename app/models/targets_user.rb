class TargetsUser < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  belongs_to :target
end
