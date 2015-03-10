require 'rails_helper'

describe Question do
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

  describe :trending! do
    let (:q) {FactoryGirl.create :question, trending_multiplier: trending_multiplier}

    context "When the trending_multiplier is 1" do
      let(:trending_multiplier) {1}

      it "Should increment the trending_index by 1" do
        expect { q.trending! }.to change { q.trending_index }.by 1
      end
    end

    context "When the trending_multiplier is 42" do
      let(:trending_multiplier) {42}

      it "Should increment the trending_index by 42" do
        expect { q.trending! }.to change { q.trending_index }.by 42
      end
    end
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
