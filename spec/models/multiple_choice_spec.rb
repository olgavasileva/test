require 'spec_helper'

describe MultipleChoice do
  describe :validations do
    it {FactoryGirl.build(:multiple_choice).should be_valid}
    it {FactoryGirl.build(:multiple_choice, title:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice, rotate:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice, muex:nil).should_not be_valid}
  end

  describe :defaults do
    let(:choice) {FactoryGirl.build :multiple_choice}

    it {choice.should be_valid}
    it {choice.muex.should be_false}
    it {choice.rotate.should be_false}
  end

  describe :relations do
    let(:choice) {FactoryGirl.create :multiple_choice}

    it {choice.should be_valid}
    it {choice.question.should be_present}
    it {choice.question.class.should eq MultipleChoiceQuestion}
  end
end
