class Segment < ActiveRecord::Base
  belongs_to :user
  has_many :response_matchers, dependent: :destroy

  validates :name, presence: true

  # Returns and AREL object of users
  def matched_users

    # Union of all response_matchers' users
    user_ids = []
    response_matchers.each do |matcher|
      user_ids += matcher.matched_users.pluck :id
    end

    User.find user_ids.uniq
  end
end
