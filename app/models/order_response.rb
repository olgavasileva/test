class OrderResponse < Response
  has_many :choice_responses, class_name:"OrderChoicesResponse"
  has_many :choices, through: :responses

  accepts_nested_attributes_for :choice_responses
end