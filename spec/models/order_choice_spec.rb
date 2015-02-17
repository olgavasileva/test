require 'rails_helper'

describe OrderChoice do

  let(:question) { OrderQuestion.new }
  let(:choice) { OrderChoice.new(question: question) }

  describe '#top_count' do
    before do
      allow(question).to receive_message_chain(:choices, :size) { 5 }
      allow(question).to receive_message_chain(:responses, :size) { 3 }
      allow(choice).to receive(:order_choices_responses).and_return([
        OrderChoicesResponse.new(position: 1),
        OrderChoicesResponse.new(position: 2),
        OrderChoicesResponse.new(position: 5),
      ])
    end

    it 'calculates the correct weighted score' do
      expect(choice.top_count).to eq(10)
    end
  end

  describe '#response_ratio' do
    before do
      allow(question).to receive_message_chain(:choices, :size) { 3 }
      allow(question).to receive_message_chain(:responses, :size) { 12 }
      allow(choice).to receive(:top_count).and_return(19)
    end

    it 'calculates the correct percent of the total' do
      expect(choice.response_ratio).to eq(0.2639)
    end

    context 'when #top_count is 0' do
      before { allow(choice).to receive(:top_count).and_return(0.0) }

      it 'returns 0' do
        expect(choice.response_ratio).to eq(0.0)
      end
    end
  end
end
