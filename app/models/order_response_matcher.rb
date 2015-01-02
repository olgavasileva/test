class OrderResponseMatcher < ResponseMatcher
  belongs_to :first_place_choice, class_name: "OrderChoice"

  validates :first_place_choice, presence: true, if: :specific_responders?

  protected
    # Must return an AREL object
    def matched_users_for_specific_response
      Respondent.joins(order_responses: :choice_responses).where(order_choices_responses: {order_choice_id: first_place_choice.id, position: 1})
    end
end