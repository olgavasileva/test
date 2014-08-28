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

    describe :response_ratios do
      it "returns choice response ratios" do
        q.choices = FactoryGirl.create_list(:choice, 4, question: q)

        q.responses = FactoryGirl.create_list(:choice_response, 3,
                                             choice: q.choices[0])

        q.responses << FactoryGirl.create(:choice_response,
                                         choice: q.choices[1])

        expect(q.response_ratios).to eq(
          q.choices[0] => 0.75,
          q.choices[1] => 0.25,
          q.choices[2] => 0,
          q.choices[3] => 0
        )
      end
    end
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

end
