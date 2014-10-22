class EnterpriseTarget < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :segments

  default min_age: 14
  default max_age: nil
  default gender: nil

  validates :user, presence: true
  validates :min_age, numericality: { only_integer: true, greater_than: 13 }
  validates :max_age, numericality: { only_integer: true, greater_than_or_equal_to: :min_age, allow_nil: true }
  validates :gender, inclusion: { in: %w(male female both) }

  def apply_to_question question
    # TODO
  end
end
