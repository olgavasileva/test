require 'rails_helper'

describe Question do

  describe 'validation' do
    it { is_expected.to allow_value(nil).for(:category_id) }

    it { is_expected.to allow_value(FactoryGirl.create(:category).id)
          .for(:category_id) }

    it { is_expected.to_not allow_value(787878).for(:category_id)
          .with_message(/does not exist/, against: :base) }

    context 'when creating' do
      let(:question) { Question.new }

      it 'forces rotate to true' do
        question.rotate = false
        question.valid?
        expect(question.rotate).to eq(true)
      end
    end
  end

  describe :image_question do
    let(:q) {FactoryGirl.build :image_question}

    it {expect(q).to be_valid}
    it {q.responses.build.class.should eq ImageResponse}
  end

  describe :text_question do
    let(:q) {FactoryGirl.build :text_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq TextResponse}
  end

  describe :choice_question do
    let(:q) { FactoryGirl.create :choice_question }
  end

  describe :text_choice_question do
    let(:q) {FactoryGirl.build :text_choice_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq TextChoiceResponse}
  end

  describe :multiple_choice_question do
    let(:q) {FactoryGirl.build :multiple_choice_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq MultipleChoiceResponse}
  end

  describe :star_question do
    let(:q) {FactoryGirl.build :star_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq StarResponse}
  end

  describe :percent_question do
    let(:q) {FactoryGirl.build :percent_question}

    it {q.should be_valid}
    it {q.responses.build.class.should eq PercentResponse}
  end

  describe :order_question do
    let(:q) {FactoryGirl.build :order_question}

    it {q.should be_valid}
    it {expect(q.responses.build.class).to eq OrderResponse}
  end

  describe :notifiable? do
    let(:notifying) { false }
    subject { Question.new(notifying: notifying).notifiable? }

    context 'when notifying is true' do
      let(:notifying) { true }
      it { is_expected.to eq(false) }
    end

    context 'when notifying is false' do
      it { is_expected.to eq(true) }
    end
  end

  describe :choice_result_cache do
    subject { Question.new.choice_result_cache }
    it { is_expected.to be_a(ChoiceResultCache) }
  end

  describe '#ordered_choices_for' do
    it 'delegates to QuestionChoiceOrderer correctly' do
      question = Question.new
      user = User.new

      orderer = question.ordered_choices_for(user)
      expect(orderer).to be_a(QuestionChoiceOrderer)
      expect(orderer.question).to eq(question)
      expect(orderer.reader).to eq(user)
    end
  end
end
