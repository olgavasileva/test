require 'nokogiri'
class AdvancedListicleParser

  INDICATORS = {
      listicle_intro: '=intro',
      item: '=item',
      listicle_footer: '=footer'
  }

  def initialize(text, listicle)
    @text, @listicle = text, listicle
    @doc = Nokogiri::HTML(@text).css('body').first
  end

  def parse
    @listicle.intro = find_intro
  end

  private

  def find_intro
    intro = nil
    intro_el_found = false
    @doc.children.each do |el|
      if el.text == INDICATORS[:listicle_intro]
        intro_el_found = true
        next
      end
      if intro_el_found
        if el.text != INDICATORS[:item] && el.text != INDICATORS[:listicle_footer]
          intro ||= ''
          intro += el.to_xhtml
        else
          break
        end
      end
    end
    intro
  end
end