require 'nokogiri'
class ListicleQuestion < ActiveRecord::Base

  belongs_to :listicle, class_name: 'Listicle'

  delegate :user, to: :listicle, allow_nil: false

  has_many :responses, class_name: 'ListicleResponse', foreign_key: :question_id, dependent: :destroy

  def score
    users_responses = {}
    responses.pluck(:is_up, :user_id, :created_at).each do |response|
      users_responses[response.second] ||= []
      users_responses[response.second] << [response.first, response.last]
    end

    score = 0
    users_responses.each do |_, v|
      user_responses = v.sort_by { |el| el.last }.map { |x| x.first ? 1 : -1 }
      case user_responses.length
        when 1 then
          score += user_responses.first
        else
          delta = 0
          # we need only last responses
          delta = user_responses.last if user_responses.last == user_responses[-2]
          score += delta
      end
    end
    score
  end

  def title(length = 15)
    Nokogiri::HTML(body).text.slice(0..length)
  end

  def answer_from(user)
    responses.find_by(user_id: user.id)
  end
end
