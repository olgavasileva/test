class ListicleQuestion < ActiveRecord::Base

  validates_presence_of :body

  belongs_to :listicle, class_name: 'Listicle'

  delegate :user, to: :listicle, allow_nil: false

  has_many :responses, class_name: 'ListicleResponse', foreign_key: :question_id

  def score
    responses.positive.count - responses.negative.count
  end

  def answer_from(user)
    responses.find_by(user_id: user.id)
  end

  def answer!(new_answer)
    old_answer = answer_from new_answer.user
    if old_answer.present?
      old_answer.destroy unless new_answer.is_up == old_answer.is_up
    else
      new_answer.save
    end
  end
end
