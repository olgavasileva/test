class ImageChoiceResponse < Response
  belongs_to :choice, class_name: "ImageChoice"

  validates :choice, presence: true

  def description
    choice.id
  end

  def csv_data
    question.choices.order(:id).map{ |c| c == choice ? 1 : 0 }
  end
end