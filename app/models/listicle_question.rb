require 'nokogiri'
class ListicleQuestion < ActiveRecord::Base

  belongs_to :listicle, class_name: 'Listicle'

  delegate :user, to: :listicle, allow_nil: false

  has_many :responses, class_name: 'ListicleResponse', foreign_key: :question_id, dependent: :destroy

  def score
    responses.pluck(:score).sum
  end

  def answer(answer, user, request)
    session_timeout = Setting.fetch_value('listicle_session_timeout')
    if session_timeout.nil?
      session_timeout = 30.minutes
    else
      session_timeout = (session_timeout.to_i / 1000).seconds
    end
    response = responses.where(user_id: user.id).order(:created_at => :desc).first
    if response.nil? || Time.zone.now - response.updated_at >= session_timeout
      response = responses.new(user_id: user.id)
    end
    response.original_referrer = request.referrer
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

  def csv_columns
    [body, script]
  end

end
