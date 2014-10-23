class Survey < ActiveRecord::Base
  has_many :questions_surveys, -> { order "position ASC" }, dependent: :destroy
  has_many :questions, through: :questions_surveys
  has_many :contests

  accepts_nested_attributes_for :questions_surveys, allow_destroy: true
end
