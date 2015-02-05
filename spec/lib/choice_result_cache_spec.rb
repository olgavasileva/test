require 'rails_helper'
require 'choice_result_cache'

RSpec.describe ChoiceResultCache do

  let(:question) { Question.new }
  let(:cache) { ChoiceResultCache.new(question) }

  describe '#response_ratio_for' do
    it 'delegates to the choice_ratios hash' do
      expect(cache).to receive(:choice_ratios).and_return(1 => :ratio)
      choice = double('Choice', id: 1)
      expect(cache.response_ratio_for(choice)).to eq(:ratio)
    end
  end

  describe '#choice_ratios' do
    let(:response_count) { 42 }
    let(:test_choices) do
      [
        double('Choice', id: 1, responses: [*1..10]),
        double('Choice', id: 2, responses: [*1..5]),
        double('Choice', id: 3, responses: [*1..13]),
        double('Choice', id: 4, responses: [*1..14])
      ]
    end

    before do
      allow(cache).to receive(:response_count) { response_count }
      allow(question).to receive(:choices).and_return(test_choices)
    end

    context 'when all choices have responses' do
      it 'calculates the correct ratios' do
        expect(cache.choice_ratios[1]).to eq(0.24)
        expect(cache.choice_ratios[2]).to eq(0.12)
        expect(cache.choice_ratios[3]).to eq(0.31)
        expect(cache.choice_ratios[4]).to eq(0.33)
      end
    end

    context 'when some choices do not have responses' do
      let(:response_count) { 12 }
      let(:test_choices) do
        [
          double('Choice', id: 1, responses: [*1..7]),
          double('Choice', id: 2, responses: [*1..5]),
          double('Choice', id: 3, responses: [])
        ]
      end

      it 'calculates the correct ratios' do
        expect(cache.choice_ratios[1]).to eq(0.58)
        expect(cache.choice_ratios[2]).to eq(0.42)
        expect(cache.choice_ratios[3]).to eq(0.00)
      end
    end

    context 'when all choices do not have responses' do
      let(:response_count) { 0 }
      let(:test_choices) do
        [
          double('Choice', id: 1, responses: []),
          double('Choice', id: 2, responses: [])
        ]
      end

      it 'calculates the correct ratios' do
        expect(cache.choice_ratios[1]).to eq(0.00)
        expect(cache.choice_ratios[2]).to eq(0.00)
      end
    end

    it 'memoizes the results' do
      expect(question).to receive(:choices).once
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
