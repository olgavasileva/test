require 'rails_helper'

describe ImageChoice do
  describe :validations do
    it {FactoryGirl.build(:image_choice).should be_valid}
    it {FactoryGirl.build(:image_choice, title:nil).should_not be_valid}
    it {FactoryGirl.build(:image_choice, rotate:nil).should be_valid}
    it {FactoryGirl.build(:image_choice, rotate:true).should be_valid}
    it {FactoryGirl.build(:image_choice, rotate:false).should be_valid}
  end

  describe :defaults do
    let(:image_choice) {FactoryGirl.build :image_choice}

    it {image_choice.should be_valid}
    it {image_choice.rotate.should eq false}
  end

  describe :relations do
    let(:image_choice) {FactoryGirl.create :image_choice}

    it {image_choice.should be_valid}
    it {image_choice.question.should be_present}
    it {image_choice.question.class.should eq ImageChoiceQuestion}
  end
end
