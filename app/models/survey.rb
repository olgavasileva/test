class Survey < ActiveRecord::Base
  has_many :questions_surveys, -> { order "questions_surveys.position ASC" }, dependent: :destroy
  has_many :questions, -> { order "questions_surveys.position ASC" }, through: :questions_surveys
  has_many :contests
  has_many :embeddable_units

  accepts_nested_attributes_for :questions_surveys, allow_destroy: true

  def next_question question
    q = questions_surveys.where(question_id:question).first
    q.lower_items.first.try(:question) unless q.nil?
  end
end
