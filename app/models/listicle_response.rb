class ListicleResponse < ActiveRecord::Base
  belongs_to :question, class_name: 'ListicleQuestion'
  belongs_to :user, class_name: 'Respondent'

  validates_presence_of :user, :question

  scope :positive, -> { where is_up: true }
  scope :negative, -> { where is_up: false }
end
