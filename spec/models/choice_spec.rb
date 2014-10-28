require 'rails_helper'

describe "All Choice Types" do
  describe OrderChoice do
    subject {
     q = FactoryGirl.create(:order_question)
     q.choices = FactoryGirl.create_list(:order_choice, 4)
     q
    }

    before do
      2.times { FactoryGirl.create :order_response, question: subject, choices: subject.choices }
      3.times { FactoryGirl.create :order_response, question: subject, choices: subject.choices.reverse }
      subject.reload
    end

    it { expect(subject.choices.first.top_count).to eq 2 }
    it { expect(subject.choices.last.top_count).to eq 3 }
    it { expect(subject.choices.first.response_ratio).to eq 2/5.0 }
    it { expect(subject.choices.last.response_ratio).to eq 3/5.0 }
  end

  describe TextChoice do
    subject {
     choices = FactoryGirl.create_list(:text_choice, 4)
     FactoryGirl.create(:text_choice_question, choices:choices)
    }

    before do
      2.times { FactoryGirl.create :text_choice_response, question: subject, choice: subject.choices.first }
      3.times { FactoryGirl.create :text_choice_response, question: subject, choice: subject.choices.last }
      subject.reload
    end

    it { expect(subject.choices.first.response_ratio).to eq 2/5.0 }
    it { expect(subject.choices.last.response_ratio).to eq 3/5.0 }
  end

  describe ImageChoice do
    subject {
     choices = FactoryGirl.create_list(:image_choice, 4)
     FactoryGirl.create(:image_choice_question, choices:choices)
    }

    before do
      2.times { FactoryGirl.create :image_choice_response, question: subject, choice: subject.choices.first }
      3.times { FactoryGirl.create :image_choice_response, question: subject, choice: subject.choices.last }
      subject.reload
    end

    it { expect(subject.choices.first.response_ratio).to eq 2/5.0 }
    it { expect(subject.choices.last.response_ratio).to eq 3/5.0 }
  end

  describe MultipleChoice do
    subject {
     choices = FactoryGirl.create_list(:multiple_choice, 4)
     FactoryGirl.create(:multiple_choice_question, choices:choices)
    }

    before do
      2.times { FactoryGirl.create :multiple_choice_response, question: subject, choices: [subject.choices.first] }
      3.times { FactoryGirl.create :multiple_choice_response, question: subject, choices: [subject.choices.last] }
      subject.reload
    end

    it { expect(subject.choices.first.response_ratio).to eq 2/5.0 }
    it { expect(subject.choices.last.response_ratio).to eq 3/5.0 }
  end
end
