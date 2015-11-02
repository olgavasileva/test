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
    text.nil? || text.empty? ? '' : text
  end

  def advanced_template_text(listicle)
    template_text = "=intro\n#{listicle.intro.try(:html_safe)}\n"
    listicle.questions.each do |q|
      template_text += '=item' + (q.id.present? ? "(#{q.id})" : '') + "\n#{q.body.try(:html_safe)}\n"
    end
    template_text + "=footer\n#{listicle.footer.try(:html_safe)}"
  end

  DEFAULT_COLORS = {
      item_separator: '#C9C9C9',
      vote_count: '#3EACE7',
      arrows_default: '#B8E2F6',
      arrows_on_hover: '#3EACE7',
      arrows_selected: '#3EACE7'
  }

  def color(listicle, property)
    if listicle.respond_to?(property.to_s + '_color')
      color = listicle.send(property.to_s + '_color')
      if color.present?
        color
      else
        DEFAULT_COLORS[property]
      end
    end
  end

end