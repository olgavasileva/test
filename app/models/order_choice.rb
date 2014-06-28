class OrderChoice < Choice
  has_and_belongs_to_many :responses, join_table: :order_choices_response
end