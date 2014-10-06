require 'rails_helper'

describe TextChoice do
  describe :validations do
    it {expect(FactoryGirl.build(:text_choice)).to be_valid}
    it {FactoryGirl.build(:text_choice, title:nil).should_not be_valid}
    it {FactoryGirl.build(:text_choice, rotate:nil).should be_valid}
    it {FactoryGirl.build(:text_choice, rotate:true).should be_valid}
    it {FactoryGirl.build(:text_choice, rotate:false).should be_valid}
  end

  describe :defaults do
    let(:text_choice) {FactoryGirl.build :text_choice}

    it {text_choice.should be_valid}
    it {text_choice.rotate.should eq false}
  end

  describe :relations do
    let(:text_choice) {FactoryGirl.create :text_choice}

    it {text_choice.should be_valid}
    it {text_choice.question.should be_present}
    it {text_choice.question.class.should eq TextChoiceQuestion}
  end
end
