require 'rails_helper'

describe MultipleChoiceResponse do
  it { is_expected.to have_many(:choices_responses) }
  it { is_expected.to have_many(:choices).through(:choices_responses) }

  describe '#text' do
    before do
      subject.choices = FactoryGirl.build_list(:multiple_choice, 2)
    end

    it "returns combined text of choices" do
      expect(subject.text).to eq(subject.choices.map(&:title).join(', '))
    end
  end
end
