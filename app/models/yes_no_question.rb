class YesNoQuestion < TextChoiceQuestion
  has_many :yes_no_choices, class_name: "TextChoice", foreign_key: :question_id, inverse_of: :question
end