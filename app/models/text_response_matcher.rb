class TextResponseMatcher < ResponseMatcher
  validates :regex, presence: true
end