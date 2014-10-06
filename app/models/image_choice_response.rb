class ImageChoiceResponse < Response
  belongs_to :choice, class_name: "ImageChoice"

  validates :choice, presence: true

  def description
    choice.id
  end
end