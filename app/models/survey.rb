class Survey < ActiveRecord::Base

  belongs_to :user, class_name: 'Respondent'

  has_many :questions_surveys, -> { order "questions_surveys.position ASC" }, dependent: :destroy
  has_many :questions, -> { order "questions_surveys.position ASC" }, through: :questions_surveys
  has_many :contests
  has_many :embeddable_units, dependent: :destroy

  accepts_nested_attributes_for :questions_surveys, allow_destroy: true

  validates :uuid, presence: true
  validate :user_exists?

  default :uuid do |eu|
    "S"+UUID.new.generate.gsub(/-/, '')
  end

  def next_question question
    q = questions_surveys.where(question_id:question).first
    q.lower_items.first.try(:question) unless q.nil?
  end

  private

  def user_exists?
    errors.add(:user, :must_exist) unless user.present?
  end
end
