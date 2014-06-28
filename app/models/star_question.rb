class StarQuestion < ChoiceQuestion
  has_many :choices, class_name:"StarChoice", foreign_key: :question_id
  has_many :responses, class_name:"StarResponse", foreign_key: :question_id

  validates :max_stars, numericality: { only_integer: true, greater_than: 0 }
end