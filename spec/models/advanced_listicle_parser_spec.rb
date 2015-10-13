require 'rails_helper'

describe AdvancedListicleParser do

  before :each do
    @listicle = Listicle.new
    @intro_indicator = '<p>=intro</p>'
    @item_indicator = '<p>=item</p>'
    @footer_indicator = '<p>=footer</p>'
  end

  it 'should parse intro' do
    run_parser @intro_indicator
    expect(@listicle.intro).to be nil

    run_parser(@intro_indicator + '<a>blahblahblah</a>')
    expect(@listicle.intro).to eq '<a>blahblahblah</a>'

    run_parser(@intro_indicator + '<a>blahblahblah</a>' + @item_indicator)
    expect(@listicle.intro).to eq '<a>blahblahblah</a>'

    run_parser(@intro_indicator + '<a>blahblahblah<i>embedded tag</i></a>' + @item_indicator)
    expect(@listicle.intro).to eq '<a>blahblahblah<i>embedded tag</i></a>'

    run_parser(@intro_indicator + '<a>blahblahblah<i>embedded tag</i></a>' + @item_indicator + '<p>another tag</p>' +@footer_indicator)
    expect(@listicle.intro).to eq '<a>blahblahblah<i>embedded tag</i></a>'
  end

  def run_parser(text)
    @parser = AdvancedListicleParser.new text, @listicle
    @parser.parse
  end
end