class OrderResponseMatcher < ResponseMatcher
  belongs_to :first_place_choice, class_name: "OrderChoice"

  validates :first_place_choice, presence: true, if: :specific_responders?
end