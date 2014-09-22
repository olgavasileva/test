class ResponseMatcher < ActiveRecord::Base
  belongs_to :segment
  belongs_to :question
end
