class OrderResponse < Response
  has_many :choice_responses, class_name:"OrderChoicesResponse"
  has_many :choices, through: :choice_responses, class_name: 'OrderChoice'

  accepts_nested_attributes_for :choice_responses

  def text
    top_choice.title
  end

  # Set choices with positions based on positions in list.
  def choices=(value)
    self.choice_ids = value.map(&:id)
  end

  # Set choices with positions based on positions in list.
  def choice_ids=(value)
    self.choice_responses = value.map.with_index do |choice_id, i|
      cr = choice_responses.where(order_choice_id: choice_id).first_or_initialize
      cr.position = i + 1
      cr.save!

      cr
    end
  end

  def description
    top_choice.id
  end

  def top_choice
    choice_responses.sort_by(&:position).first.choice
  end

  def csv_data
    choice_responses.order(:order_choice_id).pluck(:position)
  end
end
