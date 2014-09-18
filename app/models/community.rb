class Community < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true
end
