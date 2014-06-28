class PercentQuestion < ChoiceQuestion
  has_many :choices, class_name:"PercentChoice", foreign_key: :question_id
  has_many :responses, class_name:"PercentResponse", foreign_key: :question_id
end