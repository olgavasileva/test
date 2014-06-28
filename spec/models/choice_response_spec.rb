require 'spec_helper'

describe ChoiceResponse do
  describe :validations do
    it {FactoryGirl.build(:choice_response).should be_valid}
  end

  describe :relations do
    let(:choice_response) {FactoryGirl.create :choice_response}

    it {choice_response.should be_valid}
    it {choice_response.question.should be_present}
    it {choice_response.question.class.should eq ChoiceQuestion}
    it {choice_response.choice.should be_present}
    it {choice_response.choice.class.should eq Choice}
  end
end
