class OrderQuestion < ChoiceQuestion
  include BackgroundImageFromChoices

  belongs_to :background_image
  has_many :choices, class_name:"OrderChoice", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :responses, class_name:"OrderResponse", foreign_key: :question_id
  has_many :response_matchers, class_name:"OrderResponseMatcher", foreign_key: :question_id

  accepts_nested_attributes_for :choices

  def choice_top_counts
    top_counts = Hash[choices.map { |c| [c, 0] }]

    responses.each do |response|
      top_counts[response.top_choice] += 1
    end

    top_counts
  end

  def response_ratios
    ratios = {}

    choice_top_counts.each do |choice, count|
      ratios[choice] = count / responses.count.to_f
    end

    ratios
  end
end
