class OrderChoice < Choice
  has_many :order_choices_responses
  has_many :responses, through: :order_choices_responses
  mount_uploader :image, OrderChoiceImageUploader
end