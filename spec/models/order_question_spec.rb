require 'rails_helper'

describe OrderQuestion do
  subject {
   q = FactoryGirl.create(:order_question)
   q.choices = FactoryGirl.create_list(:order_choice, 4)
   q
  }

  before do
    2.times { OrderResponse.create!(question: subject, choices: subject.choices) }
    3.times { OrderResponse.create!(question: subject, choices: subject.choices.reverse) }
    subject.reload
  end

  describe :choice_top_counts do
    it "is a hash of choices and their response top position counts" do
      expect(subject.choice_top_counts).to eq(
        subject.choices[0] => 2,
        subject.choices[1] => 0,
        subject.choices[2] => 0,
        subject.choices[3] => 3
      )
    end
  end

  describe :response_ratios do
    it "is ratios of response top choices" do
      expect(subject.response_ratios).to eq(
        subject.choices[0] => 0.4,
        subject.choices[1] => 0.0,
        subject.choices[2] => 0.0,
        subject.choices[3] => 0.6
      )
    end
  end
end
