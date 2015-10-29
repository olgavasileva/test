require 'rails_helper'

describe AdvancedListicleParser do

  it 'parses intro' do
    run_parser intro_indicator do |listicle|
      expect(listicle.intro).to be nil
    end

    run_parser(intro_indicator + '<a>blahblahblah</a>') do |listicle|
      expect(listicle.intro).to eq '<a>blahblahblah</a>'
    end

    run_parser(intro_indicator + '<a>blahblahblah</a>' + item_indicator) do |listicle|
      expect(listicle.intro).to eq '<a>blahblahblah</a>'
    end

    run_parser(intro_indicator + '<a>blahblahblah<i>embedded tag</i></a>' + item_indicator) do |listicle|
      expect(listicle.intro).to eq '<a>blahblahblah<i>embedded tag</i></a>'
    end

    run_parser(intro_indicator + '<a>blahblahblah<i>embedded tag</i></a>' + item_indicator + '<p>another tag</p>' + footer_indicator) do |listicle|
      expect(listicle.intro).to eq '<a>blahblahblah<i>embedded tag</i></a>'
    end
  end

  it 'parses items(0+)' do
    run_parser item_indicator + 'hello' do |listicle|
      expect(listicle.intro.present?).to be false
      expect(listicle.questions.length).to eq 1
      expect(listicle.questions.first.body).to eq 'hello'
    end

    #accept empty item body
    run_parser intro_indicator + '<span style="color: red">intro</span>' + item_indicator do |listicle|
      expect(listicle.intro).to eq '<span style="color: red">intro</span>'
      expect(listicle.questions.length).to eq 1
      expect(listicle.questions.first.body).to eq ''
    end

    #seperate intro from item
    run_parser intro_indicator + '<span style="color: red">intro</span>' + item_indicator + 'hello' do |listicle|
      expect(listicle.intro).to eq '<span style="color: red">intro</span>'
      expect(listicle.questions.length).to eq 1
      expect(listicle.questions.first.body).to eq 'hello'
    end

    #multiple tags for item
    run_parser item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>' do |listicle|
      expect(listicle.questions.length).to eq 1
      expect(listicle.questions.first.body).to eq '<a href="hello">hello</a><ul><li>text</li></ul>'
    end

    #with footer
    run_parser intro_indicator + '<span style="color: red">intro</span>' + item_indicator + 'hello' + footer_indicator do |listicle|
      expect(listicle.intro).to eq '<span style="color: red">intro</span>'
      expect(listicle.questions.length).to eq 1
      expect(listicle.questions.first.body).to eq 'hello'
    end

    #multiple items
    run_parser item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>' + item_indicator + 'another item' do |listicle|
      expect(listicle.questions.length).to eq 2
      expect(listicle.questions.first.body).to eq '<a href="hello">hello</a><ul><li>text</li></ul>'
      expect(listicle.questions.last.body).to eq 'another item'
    end

    #multiple items with intro and footer
    run_parser intro_indicator + 'intro' + item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>' +
                   item_indicator + 'another item' + footer_indicator do |listicle|
      expect(listicle.intro).to eq 'intro'
      expect(listicle.questions.length).to eq 2
      expect(listicle.questions.first.body).to eq '<a href="hello">hello</a><ul><li>text</li></ul>'
      expect(listicle.questions.last.body).to eq 'another item'
    end

    #with empty items
    run_parser intro_indicator + item_indicator + item_indicator do |listicle|
      expect(listicle.intro).to eq nil
      expect(listicle.questions.length).to eq 2
      expect(listicle.questions.first.body).to eq ''
      expect(listicle.questions.last.body).to eq ''
    end
  end

  it 'parse footer' do
    run_parser intro_indicator + 'intro' + item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>' +
                   item_indicator + 'another item' + footer_indicator + '<p>footer <i>text</i></p>' do |listicle|
      expect(listicle.footer).to eq '<p>footer <i>text</i></p>'
    end
  end

  def item_indicator(id=nil)
    id_str = id ? ('(' + id + ')') : ''
    "<p>=item#{id_str}</p>"
  end

  def intro_indicator
    '<p>=intro</p>'
  end

  def footer_indicator
    '<p>=footer</p>'
  end

  def run_parser(text, &block)
    listicle = Listicle.new
    AdvancedListicleParser.new(text, listicle).parse_and_save
    block.call(listicle)
  end
end