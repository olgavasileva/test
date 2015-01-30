class TextChoiceResponse < Response
  belongs_to :choice, class_name: "TextChoice"

  validates :choice, presence: true

  def text
    choice.try(:title)
  end

  def description
    text
  end

  def csv_data
    [choice.try(:title)]
  end
end
