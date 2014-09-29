class TextResponse < Response
  validates :text, presence:true

  def description
    text
  end
end