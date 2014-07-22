class ImageChoiceQuestion < ChoiceQuestion
  has_many :choices, foreign_key: :question_id, class_name: "ImageChoice", dependent: :destroy
  has_many :responses, class_name:"ImageChoiceResponse", foreign_key: :question_id
end