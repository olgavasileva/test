class MultipleChoice < Choice
  belongs_to :question, class_name:"MultipleChoiceQuestion", inverse_of: :choices
  belongs_to :background_image
  has_many :choices_responses
  has_many :responses, through: :choices_responses

  default background_image_id: lambda{ |q| CannedChoiceImage.pluck(:id).sample }
  default muex: false

  validates :background_image, presence: true
  validates :muex, inclusion:{in:[true,false]}

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image
end
