class LikedComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :response
end