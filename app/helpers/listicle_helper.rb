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

  def advanced_template_text(listicle)
    template_text = "=intro\n#{listicle.get_intro.html_safe}\n"
    listicle.questions.each { |q| template_text += "=item(#{q.id})\n#{q.body.html_safe}\n" }
    template_text += "=footer\n#{listicle.footer.html_safe}"
    template_text
  end
end