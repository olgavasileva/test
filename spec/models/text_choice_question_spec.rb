require 'rails_helper'

describe TextChoiceQuestion do
  describe :validations do
    it {except(FactoryGirl.build(:text_choice_question)).to be_valid}
    it {FactoryGirl.build(:text_choice_question, title:nil).should_not be_valid}
    it {FactoryGirl.build(:text_choice_question, rotate:nil).should_not be_valid}
    it {FactoryGirl.build(:text_choice_question, image:nil).should_not be_valid}
  end

  describe :defaults do
    let(:text_choice_question) {FactoryGirl.build :text_choice_question}

    it {except(text_choice_question).to be_valid}
    it {text_choice_question.rotate.should eq false}
    it {text_choice_question.image.path.should_not be_nil}
  end
end
