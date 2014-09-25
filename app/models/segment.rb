class Segment < ActiveRecord::Base
  belongs_to :user
  has_many :response_matchers, dependent: :destroy

  validates :name, presence: true
end
