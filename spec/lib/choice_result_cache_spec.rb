require 'rails_helper'
require 'choice_result_cache'

RSpec.describe ChoiceResultCache do
  let(:question) { Question.new }
  let(:cache) { ChoiceResultCache.new(question) }

  let(:test_choices) do
    [
      double('Choice', id: 1, responses: [*1..10]),
      double('Choice', id: 2, responses: [*1..5]),
      double('Choice', id: 3, responses: [*1..13]),
      double('Choice', id: 4, responses: [*1..14])
    ]
  end

  describe '#response_ration_for' do
    it 'delegates to the choice_ratios hash' do
      expect(cache).to receive(:choice_ratios).and_return(1 => :ratio)
      choice = double('Choice', id: 1)
      expect(cache.response_ratio_for(choice)).to eq(:ratio)
    end
  end

  describe '#choice_ratios' do
    it 'calculates the correct ratios' do
      allow(cache).to receive(:response_count) { 42 }
      allow(question).to receive(:choices).and_return(test_choices)

      expect(cache.choice_ratios[1]).to eq(0.24)
      expect(cache.choice_ratios[2]).to eq(0.12)
      expect(cache.choice_ratios[3]).to eq(0.31)
      expect(cache.choice_ratios[4]).to eq(0.33)
    end

    it 'memoizes the results' do
      allow(cache).to receive(:response_count).once.and_return(1)
      allow(question).to receive(:choices).once.and_return([
        double('Choice', id: 1, responses: [1]),
      ])

      cache.choice_ratios
      cache.choice_ratios
    end
  end

  describe 'response_count' do
    it 'delegates to the question attribute' do
      expect(question).to receive(:responses) { [1, 2, 3] }
      expect(cache.response_count).to eq(3)
    end
  end
end
