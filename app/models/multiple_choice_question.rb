class MultipleChoiceQuestion < ChoiceQuestion
  include BackgroundImageFromChoices

  belongs_to :background_image
  has_many :multiple_choices, foreign_key: :question_id, dependent: :destroy
  has_many :choices, class_name:"MultipleChoice", foreign_key: :question_id, inverse_of: :question
  has_many :responses, class_name:"MultipleChoiceResponse", foreign_key: :question_id

  default min_responses: 2
  default max_responses: 2

  validates :min_responses, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_responses, numericality: { only_integer: true, greater_than_or_equal_to: :min_responses, allow_nil: true }

  accepts_nested_attributes_for :choices, allow_destroy:true

  # Returns the number of individual responses - override if multiple choices are allowed
  def choice_count
    responses.joins(:choices).count
  end
end
