require 'question_choice_orderer'

RSpec.describe QuestionChoiceOrderer do

  let(:choices) { [] }
  let(:question) { Question.new }
  let(:reader) { User.new }

  let(:orderer) { described_class.new(question, reader) }

  it 'is Enumerable' do
    allow(orderer).to receive(:question_choices).and_return([1, 2])
    expect { |b| orderer.each(&b) }.to yield_successive_args(1, 2)
  end

  describe '#question_choices' do
    it 'delegates to #randomize_question_choices and memoizes the result' do
      expect(orderer).to receive(:randomize_question_choices)
        .once.and_return([1, 2])

      orderer.question_choices
      orderer.question_choices
    end
  end

  describe '#randomize_question_choices' do
    let(:choices) do
      [
        Choice.new(id: 2),
        Choice.new(id: 3),
        Choice.new(id: 4),
        Choice.new(id: 5, position: 0),
        Choice.new(id: 1, position: 2)
      ]
    end

    before { allow(orderer).to receive(:choice_query).and_return(choices) }

    it 'ensures choices with defined positions are in the correct order' do
      result = orderer.send(:randomize_question_choices)
      expect(result[0].id).to eq(5)
      expect(result[2].id).to eq(1)
    end

    context 'when the question does not rotate' do
      let(:question) { Question.new(rotate: false) }

      it 'returns the default choice order' do
        result = orderer.send(:randomize_question_choices).map(&:id)
        expect(result).to eq([5, 2, 1, 3, 4])
      end
    end

    context 'when the question does rotate' do
      let(:question) { Question.new(rotate: false) }

      context 'given a reader with a seedable id' do
        let(:reader) { User.new(id: 1) }

        it 'randomizes the order in a reproducible way for that reader' do
          first = orderer.send(:randomize_question_choices).map(&:id)
          second = orderer.send(:randomize_question_choices).map(&:id)
          expect(first).to eq(second)
        end
      end
    end
  end
end
