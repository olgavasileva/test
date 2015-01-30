class TextResponse < Response
  validates :text, presence:true

  def description
    text
  end

  def csv_data
    [text]
  end
end