class ChoiceQuestion < Question
  has_many :choices, foreign_key: :question_id, dependent: :destroy
  has_many :responses, class_name:"ChoiceResponse", foreign_key: :question_id

  default rotate: true

  validates :rotate, inclusion: {in:[true,false]}
end