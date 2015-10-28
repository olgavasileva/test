require 'nokogiri'
class AdvancedListicleParser

  INDICATORS = {
      listicle_intro: /\A=intro\z/,
      item: /\A=item\(?\d*?\)?\z/,
      listicle_footer: /\A=footer\z/
  }

  def initialize(text, listicle)
    @text, @listicle = text, listicle
    @doc = Nokogiri::HTML(@text).css('body').first
  end

  def parse
    @listicle.intro = find_intro
    @listicle.questions = find_questions
    @listicle.footer = find_footer
  end

  private

  def find_intro
    intro = nil
    (0...root_elements.length).each do |i|
      el = root_elements[i]
      if INDICATORS[:listicle_intro].match(el.text)
        (i+1...root_elements.length).each do |j|
          next_el = root_elements[j]
          if !INDICATORS[:item].match(next_el.text) && !INDICATORS[:listicle_footer].match(next_el.text)
            intro ||= ''
            intro += element_html(next_el)
          else
            break
          end
        end
        break
      end
    end
    intro
  end

  def find_questions
    questions = []
    (0...root_elements.length).each do |i|
      el = root_elements[i]
      if INDICATORS[:item].match(el.text)
        item = get_item(el)
        item.body ||= ''
        (i+1...root_elements.length).each do |j|
          next_el = root_elements[j]
          if !INDICATORS[:item].match(next_el.text) && !INDICATORS[:listicle_footer].match(next_el.text)
            item.body += element_html(next_el)
          else
            break
          end
        end
        questions << item
      end
    end
    questions
  end

  def get_item(item_el)
    regex = /\A=item\((\d+)\)\z/
    match = regex.match(item_el)
    if match
      id = match[1].to_i
      begin
        @listicle.questions.find(id)
      rescue ActiveRecord::NotFoundError
        ListicleQuestion.new
      end
    else
      ListicleQuestion.new
    end
  end

  def find_footer
    is_footer = false
    footer = ''
    root_elements.each do |el|
      if INDICATORS[:listicle_footer].match(el.text)
        is_footer = true
        next
      end
      footer += element_html(el) if is_footer
    end
    footer
  end

  private

  def element_html(element)
    element.to_s.gsub(/\n/, '')
  end

  def root_elements
    @doc.children
  end
end