class OrderChoicesResponse < ActiveRecord::Base
  belongs_to :choice, class_name:"OrderChoice", foreign_key: :order_choice_id
  belongs_to :response, class_name:"OrderResponse", foreign_key: :order_response_id

  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end