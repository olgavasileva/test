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

  def top_count
    order_choices_responses.where(position:1).count
  end

  def response_ratio
    question.responses.count == 0 ? 0 : top_count / question.responses.count.to_f
  end
end