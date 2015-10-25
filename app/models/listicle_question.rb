require 'nokogiri'
class ListicleQuestion < ActiveRecord::Base

  validates_presence_of :body

  belongs_to :listicle, class_name: 'Listicle'

  delegate :user, to: :listicle, allow_nil: false

  has_many :responses, class_name: 'ListicleResponse', foreign_key: :question_id

  def score
    responses.pluck(:score).sum
  end

  def answer(answer, user)
    response = responses.find_or_create_by(user_id: user.id)
    response.score += answer[:is_up] ? 1 : -1
    response.save
  end

  def title(length = 15)
    Nokogiri::HTML(body).text.slice(0..length)
  end

  def answer_from(user)
    responses.find_by(user_id: user.id)
  end
end
