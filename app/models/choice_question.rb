class ChoiceQuestion < Question
  has_many :responses, class_name:"ChoiceResponse", foreign_key: :question_id
  has_many :response_matchers, class_name:"ChoiceResponseMatcher", foreign_key: :question_id, dependent: :destroy

  default rotate: true

  validates :rotate, inclusion: {in:[true,false]}
end
