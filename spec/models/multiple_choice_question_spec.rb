require 'spec_helper'

describe MultipleChoiceQuestion do
  describe :validations do
    it {FactoryGirl.build(:multiple_choice_question).should be_valid}
    it {FactoryGirl.build(:multiple_choice_question, title:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice_question, description:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice_question, rotate:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice_question, min_responses:nil).should_not be_valid}
  end

  describe :defaults do
    let(:multiple_choice_question) {FactoryGirl.build :multiple_choice_question}

    it {multiple_choice_question.should be_valid}
    it {multiple_choice_question.rotate.should be_false}
    it {multiple_choice_question.min_responses.should eq 1}
  end
end
