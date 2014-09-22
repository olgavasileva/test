class OrderQuestion < ChoiceQuestion
  include BackgroundImageFromChoices

  belongs_to :background_image
  has_many :choices, class_name:"OrderChoice", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :responses, class_name:"OrderResponse", foreign_key: :question_id

  accepts_nested_attributes_for :choices
end
