require 'rails_helper'

describe MultipleChoiceResponse do
  describe :validations do
    it {expect(FactoryGirl.build(:multiple_choice_response)).to be_valid}
  end

  describe :relations do
    let(:multiple_choice_response) {FactoryGirl.create :multiple_choice_response}

    it {multiple_choice_response.should be_valid}
    it {multiple_choice_response.question.should be_present}
    it {multiple_choice_response.question.class.should eq MultipleChoiceQuestion}
    it {multiple_choice_response.choices_responses.build.class.should eq ChoicesResponse}
  end
end
