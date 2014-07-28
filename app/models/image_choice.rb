class ImageChoice < Choice
  has_many :responses, class_name: "ImageChoiceResponse", foreign_key: :choice_id, dependent: :destroy
end
