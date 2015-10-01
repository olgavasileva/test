require 'nokogiri'
module ListicleHelper
  def text_from_html(html)
    Nokogiri.HTML(html).text
  end

  def limit_text(text, length = 30)
    if length >= text.length
      text
    else
      text[0..length-4] + '...'
    end
  end

  def text_or_empty_symbol(text)
    text.nil? || text.empty? ? '&nbsp;' : text
  end
end