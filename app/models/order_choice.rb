class OrderChoice < Choice
  belongs_to :background_image
  belongs_to :question, class_name:"OrderQuestion", inverse_of: :choices
  has_many :order_choices_responses
  has_many :responses, through: :order_choices_responses

  default background_image_id: lambda{ |q| CannedOrderChoiceImage.pluck(:id).sample }

  validates :background_image, presence: true

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image

  # This amounts to the score (or weight) for all responses to this choice.
  def top_count
    @top_count ||= begin
      total = question.choices.size
      order_choices_responses.to_a.inject(0) do |weight, choice|
        weight + (total - choice.position + 1)
      end
    end
  end

  # This is the percent of the total available score for all responses to this
  # choice.
  def response_ratio
    @response_ratio ||= begin
      return 0.0 unless top_count > 0
      response_total = [*1..(question.choices.size)].sum
      total = (response_total * question.responses.size)
      ((top_count.to_f / total)).round(4)
    end
  end
end
