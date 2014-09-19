class OrderResponse < Response
  # todo: rename to :choices_responses
  has_many :choice_responses, class_name:"OrderChoicesResponse"
  has_many :choices, through: :choice_responses, class_name: 'OrderChoice'

  accepts_nested_attributes_for :choice_responses

  def text
    top_choices_response.choice.title
  end

  # Set choices with positions based on choice_id position in list.
  def choice_ids=(value)
    self.choice_responses = value.map.with_index do |choice_id, i|
      cr_params = { order_choice_id: choice_id, order_response_id: id }
      cr = OrderChoicesResponse.where(cr_params).first_or_initialize
      cr.position = i + 1
      cr.save!

      cr
    end
  end

  private

  def top_choices_response
    choice_responses.sort_by(&:position).first
  end

  def description
    top_choices_response.order_choice.id
  end
end
