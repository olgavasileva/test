require 'spec_helper'

describe Choice do
  describe :validations do
    it {FactoryGirl.build(:choice).should be_valid}
    it {FactoryGirl.build(:choice, title:nil).should_not be_valid}
    it {FactoryGirl.build(:choice, rotate:nil).should_not be_valid}
  end

  describe :defaults do
    let(:choice) {FactoryGirl.build :choice}

    it {choice.should be_valid}
    it {choice.rotate.should eq false}
  end

  describe :relations do
    let(:choice) {FactoryGirl.create :choice}

    it {choice.should be_valid}
    it {choice.question.should be_present}
    it {choice.question.class.should eq ChoiceQuestion}
  end
end
