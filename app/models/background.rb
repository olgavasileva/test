class Background < Sticker

  def mirrorable
    false
  end
  alias_method :mirrorable?, :mirrorable
end