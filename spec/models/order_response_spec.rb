require 'rails_helper'

describe OrderResponse do
  subject { FactoryGirl.create :order_response }

  describe :text do
    before do
      subject.choice_responses = FactoryGirl.build_list(:order_choices_response, 4)

      subject.choice_responses.each_with_index do |choices_response, i|
        choices_response.choice.title = "Choice #{i}"
        choices_response.position = i
      end
    end

    it "returns text of top choice" do
      expect(subject.text).to eq "Choice 0"
    end
  end
end
