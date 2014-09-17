class OrderResponse < Response
  # todo: rename to :choices_responses
  has_many :choice_responses, class_name:"OrderChoicesResponse"
  has_many :choices, through: :choice_responses, class_name: 'OrderChoice'

  accepts_nested_attributes_for :choice_responses

  def text
    top_choices_response.choice.title
  end

  private

  def top_choices_response
    choice_responses.sort_by(&:position).first
  end

  def description
    top_choices_response.order_choice.id
  end
end
