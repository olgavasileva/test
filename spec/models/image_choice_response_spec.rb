require 'rails_helper'

describe ImageChoiceResponse do
  describe :validations do
    it {expect(FactoryGirl.build(:image_choice_response)).to be_valid}
  end

  describe :relations do
    let(:image_choice_response) {FactoryGirl.create :image_choice_response}

    it {image_choice_response.should be_valid}
    it {image_choice_response.question.should be_present}
    it {image_choice_response.question.class.should eq ImageChoiceQuestion}
    it {image_choice_response.choice.should be_present}
    it {image_choice_response.choice.class.should eq ImageChoice}
  end
end
