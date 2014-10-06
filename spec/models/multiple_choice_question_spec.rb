require 'rails_helper'

describe MultipleChoiceQuestion do
  describe :validations do
    it {expect(FactoryGirl.build(:multiple_choice_question)).to be_valid}
    it {FactoryGirl.build(:multiple_choice_question, title:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice_question, rotate:nil).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice_question, max_responses:nil).should be_valid}
    it {FactoryGirl.build(:multiple_choice_question, min_responses:1, max_responses:0).should_not be_valid}
    it {FactoryGirl.build(:multiple_choice_question, min_responses:1, max_responses:nil).should be_valid}
    it {FactoryGirl.build(:multiple_choice_question, min_responses:1, max_responses:1).should be_valid}
    it {expect(FactoryGirl.build(:multiple_choice_question, min_responses:1, max_responses:2)).to be_valid}
    it {FactoryGirl.build(:multiple_choice_question, min_responses:2, max_responses:1).should_not be_valid}
  end

  describe :defaults do
    let(:multiple_choice_question) {FactoryGirl.build :multiple_choice_question}

    it {multiple_choice_question.should be_valid}
    it {multiple_choice_question.rotate.should be false}
    it {multiple_choice_question.min_responses.should eq 1}
  end
end
