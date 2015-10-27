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
    response = responses.find_or_initialize_by(user_id: user.id)
    old_score = response.score
    response.score += answer[:is_up] ? 1 : -1
    response.ensure_valid_score
    response.vote_count += 1 if !response.new_record? && old_score != response.score
    response.save
  end

  def title(length = 15)
    Nokogiri::HTML(body).text.slice(0..length)
  end

  def answer_from(user)
    responses.find_by(user_id: user.id)
  end

  def total_votes
    up_votes_count + down_votes_count
  end

  def net_votes
    up_votes_count - down_votes_count
  end

  def up_votes_count
    responses.positive.count
  end

  def down_votes_count
    responses.negative.count
  end

end
