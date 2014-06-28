class OrderQuestion < ChoiceQuestion
  has_many :choices, class_name:"OrderChoice", foreign_key: :question_id
  has_many :responses, class_name:"OrderResponse", foreign_key: :question_id
end