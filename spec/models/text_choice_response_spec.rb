require 'rails_helper'

describe TextChoiceResponse do
  subject { FactoryGirl.create(:text_choice_response) }

  describe :validations do
    it {expect(FactoryGirl.build(:text_choice_response)).to be_valid}
  end

  describe :relations do
    let(:text_choice_response) {FactoryGirl.create :text_choice_response}

    it {text_choice_response.should be_valid}
    it {text_choice_response.question.should be_present}
    it {text_choice_response.question.class.should eq TextChoiceQuestion}
    it {text_choice_response.choice.should be_present}
    it {text_choice_response.choice.class.should eq TextChoice}
  end

  describe :text do
    before do
      subject.choice = FactoryGirl.create(:text_choice, title: "The Choice")
    end

    it "returns choice's text" do
      expect(subject.text).to eq "The Choice"
    end
  end
end
