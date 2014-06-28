class InfoQuestion < Question
  validates :image, presence:true, if:Proc.new { |info| info.html.blank? }
  validates :html, presence:true, if:Proc.new { |info| info.image.blank? }
end