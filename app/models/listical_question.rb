class ListicalQuestion < ActiveRecord::Base

  validates_presence_of :body, :title

  belongs_to :listical, class_name: 'Listical'

  delegate :user, to: :listical, allow_nil: false

  has_many :responses, class_name: 'ListicalResponse', foreign_key: :question_id

  def score
    score = responses.positive.count - responses.negative.count
    [score, 0].max
  end
end
