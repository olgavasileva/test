require 'nokogiri'
module ListicleHelper
  def text_from_html(html)
    Nokogiri.HTML(html).text
  end
end