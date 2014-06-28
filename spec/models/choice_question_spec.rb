require 'spec_helper'

describe ChoiceQuestion do
  describe :validations do
    it {FactoryGirl.build(:choice_question).should be_valid}
    it {FactoryGirl.build(:choice_question, title:nil).should_not be_valid}
    it {FactoryGirl.build(:choice_question, description:nil).should_not be_valid}
    it {FactoryGirl.build(:choice_question, rotate:nil).should_not be_valid}
  end

  describe :defaults do
    let(:choice_question) {FactoryGirl.build :choice_question}

    it {choice_question.should be_valid}
    it {choice_question.rotate.should eq false}
  end
end
