require 'rails_helper'

describe ImageChoiceQuestion do
  describe :validations do
    it {FactoryGirl.build(:image_choice_question).should be_valid}
    it {FactoryGirl.build(:image_choice_question, title:nil).should_not be_valid}
    it {FactoryGirl.build(:image_choice_question, rotate:nil).should_not be_valid}
  end

  describe :defaults do
    let(:image_choice_question) {FactoryGirl.build :image_choice_question}

    it {image_choice_question.should be_valid}
    it {image_choice_question.rotate.should eq false}
  end
end
