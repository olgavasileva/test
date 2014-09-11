class ImageChoiceQuestion < ChoiceQuestion
  has_many :choices, class_name: "ImageChoice", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :responses, class_name:"ImageChoiceResponse", foreign_key: :question_id

  accepts_nested_attributes_for :choices
end