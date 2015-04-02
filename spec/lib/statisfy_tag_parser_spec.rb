require 'rails_helper'

RSpec.describe StatisfyTagParser do

  describe '.parse_tag' do
    it 'clears dissalowed characters' do
      tags = ['#tag', 'lol-lol', 'he;he', "That'sAwkward", 'Welcome Home bro!']
      parsed = tags.map { |t| StatisfyTagParser.parse_tag(t) }
      expected = %w{tag lollol hehe ThatsAwkward WelcomeHomebro}
      expect(parsed).to eq(expected)
    end
  end

  describe '#parse' do
    let(:parser) { StatisfyTagParser.new(['#can-I', 'kick it']) }

    it 'returns an ActsAsTaggableOn::TagList' do
      expect(parser.parse).to be_a(ActsAsTaggableOn::TagList)
    end

    it 'parses the tags' do
      expect(parser.parse).to eq(%w{cani kickit})
    end
  end
end
