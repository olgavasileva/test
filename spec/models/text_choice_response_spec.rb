require 'rails_helper'

describe TextChoiceResponse do
  describe :validations do
    it {FactoryGirl.build(:text_choice_response).should be_valid}
  end

  describe :relations do
    let(:text_choice_response) {FactoryGirl.create :text_choice_response}

    it {text_choice_response.should be_valid}
    it {text_choice_response.question.should be_present}
    it {text_choice_response.question.class.should eq TextChoiceQuestion}
    it {text_choice_response.choice.should be_present}
    it {text_choice_response.choice.class.should eq TextChoice}
  end
end
