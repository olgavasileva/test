require 'rails_helper'

describe ResponseNotificationCalculator do

  let(:worker) { described_class.new }
  let(:user) { User.new(id: 1) }

  let(:user_responses) { [] }

  let(:response_number) { 0 }
  let(:question) do
    double('Question', {
      update_attribute: nil,
      id: 1,
      user: user,
      responses: double(size: response_number)
    })
  end

  before { allow(Resque).to receive(:enqueue).and_return(nil) }

  describe '.perform' do
    it 'loads the question and performs the worker' do
      question = Question.new

      expect(Question).to receive(:eager_load)
        .with(:user, :responses).ordered { Question }

      expect(Question).to receive(:where)
        .with(id: 1, notifying: true).ordered { Question }

      expect(Question).to receive(:first) { question }

      expect_any_instance_of(described_class).to receive(:perform)
        .with(question) { nil }

      described_class.perform(1)
    end

    it 'does nothing when the question cannot be found' do
      expect_any_instance_of(described_class).to_not receive(:perform)
      described_class.perform(9999)
    end
  end

  describe '#perform' do
    it "always sets the question's :notifying attribute to false" do
      expect(question).to receive(:update_attribute).with(:notifying, false)
      worker.perform(question)
    end

    context 'with no responses' do
      it 'does not queue a ResponseNotificationSender' do
        expect(Resque).to_not receive(:enqueue)
          .with(ResponseNotificationSender, question.id)

        worker.perform(question)
      end
    end

    context 'when the current multiple is 0' do
      before { stub_multiple(0) }

      it 'does not queue a ResponseNotificationSender' do
        expect(Resque).to_not receive(:enqueue)
          .with(ResponseNotificationSender, question.id)

        worker.perform(question)
      end
    end

    context 'when the current multiple is not a match' do
      let(:response_number) { 50 }
      before { stub_multiple(49) }

      it 'does not queue a ResponseNotificationSender' do
        expect(Resque).to_not receive(:enqueue)
          .with(ResponseNotificationSender, question.id)

        worker.perform(question)
      end
    end

    context 'when the current multiple is a match' do
      let(:response_number) { 50 }
      before { stub_multiple(25) }

      it 'queues a ResponseNotificationSender' do
        expect(Resque).to receive(:enqueue)
          .with(ResponseNotificationSender, question.id)

        worker.perform(question)
      end
    end
  end

  describe '#calculate_multiple' do
    let(:default) { described_class::DEFAULT_MULTIPLE }
    subject { worker.calculate_multiple(question) }

    context 'when median is the highest' do
      before do
        stub_responses
        stub_average(default + 100)
        stub_median(default + 1000)
      end

      it { is_expected.to eq(default + 1000) }
    end

    context 'when average is the highest' do
      before do
        stub_responses
        stub_average(default + 20)
        stub_median(default + 15)
      end

      it { is_expected.to eq(default + 20) }
    end

    context 'when default is the highest' do
      before do
        stub_responses
        stub_average(default - 1)
        stub_median(default - 2)
      end

      it { is_expected.to eq(default) }
    end
  end

  describe '#fetch_response_values' do
    it 'queries for the correct responses and returns the correct values' do
      user = User.new(id: 1)
      time = 1.day.ago

      expect(Response).to receive(:joins)
        .with(question: [:user]).ordered { Response }

      expect(Response).to receive(:where)
        .with('responses.created_at >= ?', time).ordered { Response}

      expect(Response).to receive(:where)
        .with(questions: {users: {id: 1}}).ordered { Response }

      expect(Response).to receive(:group)
        .with(:question_id).ordered { Response }

      expect(Response).to receive(:count).ordered.and_return({1=>10, 2=>1})

      result = worker.fetch_response_values(user, time)
      expect(result).to eq([10, 1])
    end
  end

  describe '#calculate_average' do
    let(:questions) { 10 }
    let(:responses) { 45 }

    subject { worker.calculate_average(questions, responses) }

    context 'when the question total is 0' do
      let(:questions) { 0 }
      it { is_expected.to eq(0) }
    end

    context 'when the response total is 0' do
      let(:responses) { 0 }
      it { is_expected.to eq(0) }
    end

    context 'with non-zero values' do
      it 'returns the correct average' do
        expect(subject).to eq((responses/questions).to_i)
      end
    end
  end

  describe '#calculate_median' do
    let(:values) { [] }
    subject { worker.calculate_median(values) }

    context 'when there are no values in the array' do
      it { is_expected.to eq(0) }
    end

    context 'when there are an even number of values' do
      let(:values) { [1, 1, 1, 2, 3, 10, 10, 10] }

      it 'returns the correct value' do
        expect(subject).to eq(2)
      end
    end

    context 'when there are an odd number of values' do
      let(:values) { [1, 1, 1, 7, 10, 10, 10] }

      it 'returns the correct value' do
        expect(subject).to eq(7)
      end
    end
  end

  private

  def stub_multiple(multiple)
    allow(worker).to receive(:calculate_multiple).and_return(multiple)
  end

  def stub_responses(values=[])
    allow(worker).to receive(:fetch_response_values).and_return(values)
  end

  def stub_average(average)
    allow(worker).to receive(:calculate_average).and_return(average)
  end

  def stub_median(median)
    allow(worker).to receive(:calculate_median).and_return(median)
  end
end
