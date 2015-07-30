require 'nokogiri'
module ListicalHelper
  def text_from_html(html)
    Nokogiri.HTML(html).text
  end
end