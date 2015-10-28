require 'rails_helper'

describe AdvancedListicleParser do

  before :each do
    @listicle = Listicle.new
  end

  it 'parses intro' do
    run_parser intro_indicator
    expect(@listicle.intro).to be nil

    run_parser(intro_indicator + '<a>blahblahblah</a>')
    expect(@listicle.intro).to eq '<a>blahblahblah</a>'

    run_parser(intro_indicator + '<a>blahblahblah</a>' + item_indicator)
    expect(@listicle.intro).to eq '<a>blahblahblah</a>'

    run_parser(intro_indicator + '<a>blahblahblah<i>embedded tag</i></a>' + item_indicator)
    expect(@listicle.intro).to eq '<a>blahblahblah<i>embedded tag</i></a>'

    run_parser(intro_indicator + '<a>blahblahblah<i>embedded tag</i></a>' + item_indicator + '<p>another tag</p>' + footer_indicator)
    expect(@listicle.intro).to eq '<a>blahblahblah<i>embedded tag</i></a>'
  end

  it 'parses items(0+)' do
    run_parser item_indicator + 'hello'
    expect(@listicle.intro.present?).to be false
    expect(@listicle.questions.length).to eq 1
    expect(@listicle.questions.first.body).to eq 'hello'

    #accept empty item body
    run_parser intro_indicator + '<span style="color: red">intro</span>' + item_indicator
    expect(@listicle.intro).to eq '<span style="color: red">intro</span>'
    expect(@listicle.questions.length).to eq 1
    expect(@listicle.questions.first.body).to eq ''

    #seperate intro from item
    run_parser intro_indicator + '<span style="color: red">intro</span>' + item_indicator + 'hello'
    expect(@listicle.intro).to eq '<span style="color: red">intro</span>'
    expect(@listicle.questions.length).to eq 1
    expect(@listicle.questions.first.body).to eq 'hello'

    #multiple tags for item
    run_parser item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>'
    expect(@listicle.questions.length).to eq 1
    expect(@listicle.questions.first.body).to eq '<a href="hello">hello</a><ul><li>text</li></ul>'

    #with footer
    run_parser intro_indicator + '<span style="color: red">intro</span>' + item_indicator + 'hello' + footer_indicator
    expect(@listicle.intro).to eq '<span style="color: red">intro</span>'
    expect(@listicle.questions.length).to eq 1
    expect(@listicle.questions.first.body).to eq 'hello'

    #multiple items
    run_parser item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>' + item_indicator + 'another item'
    expect(@listicle.questions.length).to eq 2
    expect(@listicle.questions.first.body).to eq '<a href="hello">hello</a><ul><li>text</li></ul>'
    expect(@listicle.questions.last.body).to eq 'another item'

    #multiple items with intro and footer
    run_parser intro_indicator + 'intro' + item_indicator + '<a href="hello">hello</a><ul><li>text</li></ul>' +
                   item_indicator + 'another item' + footer_indicator
    expect(@listicle.intro).to eq 'intro'
    expect(@listicle.questions.length).to eq 2
    expect(@listicle.questions.first.body).to eq '<a href="hello">hello</a><ul><li>text</li></ul>'
    expect(@listicle.questions.last.body).to eq 'another item'

    #with empty items
    run_parser intro_indicator + item_indicator + item_indicator
    expect(@listicle.intro).to eq nil
    expect(@listicle.questions.length).to eq 2
    expect(@listicle.questions.first.body).to eq ''
    expect(@listicle.questions.last.body).to eq ''
  end

  it 'parse footer' do

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

  def run_parser(text)
    @parser = AdvancedListicleParser.new text, @listicle
    @parser.parse
  end
end