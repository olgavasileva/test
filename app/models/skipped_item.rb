# Deprecated - only used to update feeds from legacy table
class SkippedItem < ActiveRecord::Base
  belongs_to :user, class_name:"Respondent"
  belongs_to :question
end
