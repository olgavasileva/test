require 'rails_helper'

describe ResponseNotificationSender do

  let(:worker) { described_class.new }
  let(:user) { FactoryGirl.create(:user) }

  let(:question) do
    double('Question', {
      id: 1,
      user: user,
      title: 'What is up?',
      response_count: 12,
      comment_count: 12,
      share_count: 12,
      targeting?: true
    })
  end

  describe '.perform' do
    it 'loads the question and performs the worker' do
      expect(Question).to receive(:find).with(1) { question }
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
    it 'sends a #push to the each instance for the user' do
      instance = Instance.new

      now = Time.now
      allow(Time).to receive(:now) { now }

      expect(user).to receive_message_chain(:instances, :where, :not) { [instance] }

      expect(instance).to receive(:push).with({
        alert:'Someone responded to your question',
        badge: 1,
        sound: true,
        other: {
          type: 'QuestionUpdated',
          created_at: now,
          read_at: nil,
          question_id: question.id,
          response_count: question.response_count,
          comment_count: question.comment_count,
          share_count: question.share_count,
          completed_at: now
        }
      }) { nil }

      worker.perform(question)
    end
  end

  describe '#build_message' do
    context 'when a QuestionUpdated at record does not exist' do
      it 'creates a new QuestionUpdated record' do
        expect{
          worker.build_message(question)
        }.to change(QuestionUpdated, :count).by(1)
      end
    end

    context 'when a QuestionUpdated at record already exists' do
      before { QuestionUpdated.create(question_id: question.id) }

      it 'does not create a new QuestionUpdated record' do
        expect{
          worker.build_message(question)
        }.to_not change(QuestionUpdated, :count)
      end
    end

    it 'builds the message correctly' do
      now = Time.now
      allow(Time).to receive(:now) { now }

      message = worker.build_message(question)

      expect(message.user_id).to eq(question.user.id)
      expect(message.response_count).to eq(question.response_count)
      expect(message.comment_count).to eq(question.comment_count)
      expect(message.share_count).to eq(question.share_count)
      expect(message.read_at).to eq(nil)
      expect(message.created_at).to eq(now)
      expect(message.completed_at).to eq(now)
      expect(message.body).to include("You have #{message.response_count} responses to your question \"#{question.title}\"")
      expect(message.body).to include("and you have #{message.comment_count} comments")
      expect(message.body).to include("and your question is completed")
    end

    context 'when there are no comments' do
      before { allow(question).to receive(:comment_count) { 0 } }

      it 'does not include a message about comments' do
        message = worker.build_message(question)
        expect(message.body).to_not include("and you have #{message.comment_count} comments")
      end
    end

    context 'when the question is not #targeting?' do
      before { allow(question).to receive(:targeting?) { false } }

      it 'does not include a message about being complete' do
        message = worker.build_message(question)
        expect(message.body).to_not include("and your question is completed")
      end

      it 'does not set the :completed_at' do
        message = worker.build_message(question)
        expect(message.completed_at).to eq(nil)
      end
    end
  end
end
