class ListicleResponse < ActiveRecord::Base
  belongs_to :question, class_name: 'ListicleQuestion'
  belongs_to :user, class_name: 'Respondent'

  validates_presence_of :user, :question
  before_save :ensure_valid_score

  scope :positive, -> { where score: 1 }
  scope :negative, -> { where score: -1 }

  private

  def ensure_valid_score
    if score > 0
      self.score = 1
    elsif score < 0
      self.score = -1
    end
  end
end
