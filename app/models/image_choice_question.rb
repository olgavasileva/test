class ImageChoiceQuestion < ChoiceQuestion
  include BackgroundImageFromChoices

  belongs_to :background_image
  has_many :choices, class_name: "ImageChoice", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :image_choices, foreign_key: :question_id
  has_many :responses, class_name:"ImageChoiceResponse", foreign_key: :question_id

  accepts_nested_attributes_for :choices
end
