class ListicleQuestion < ActiveRecord::Base

  validates_presence_of :body, :title

  belongs_to :listicle, class_name: 'Listicle'

  delegate :user, to: :listicle, allow_nil: false

  has_many :responses, class_name: 'ListicleResponse', foreign_key: :question_id

  def score
    score = responses.positive.count - responses.negative.count
    [score, 0].max
  end
end
