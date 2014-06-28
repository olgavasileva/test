class ImageQuestion < Question
  has_many :responses, class_name:"ImageResponse", foreign_key: :question_id
end