require 'rails_helper'

RSpec.describe Survey do

  it { is_expected.to belong_to(:user).class_name('Respondent') }
  it { is_expected.to have_many(:embeddable_units).dependent(:destroy) }

  describe 'validations' do
    context 'for user' do
      it { is_expected.to_not allow_value(99999)
          .for(:user_id)
          .with_message(:must_exist, against: :user) }

      it { is_expected.to allow_value(FactoryGirl.create(:user)).for(:user) }
    end
  end

  describe '#thank_you_markdown' do
    it 'sets the #thank_you_html' do
      survey = Survey.new(thank_you_markdown: '**Thank You**')
      survey.send(:convert_markdown)
      expect(survey.thank_you_html).to_not be_nil
    end
  end

  describe :parsed_thank_you_html do
    it "parses a simple replacement correctly" do
      survey = Survey.new thank_you_html: "This is a %xyz%."
      hash = {"xyz" => "test"}
      expect(survey.parsed_thank_you_html hash).to eq "This is a test."
    end

    it "parses a replacement with a default correctly" do
      survey = Survey.new thank_you_html: "This is a %pdq|cat%."
      hash = {"xyz" => "test"}
      expect(survey.parsed_thank_you_html hash).to eq "This is a cat."
    end

    it "parses a multiple replacements correctly" do
      survey = Survey.new thank_you_html: "This is a %pdq|cat% with a %xyz|dog% and a %lmnop|mouse%."
      hash = {"xyz" => "spider", "pdq" => "cherry pie"}
      expect(survey.parsed_thank_you_html hash).to eq "This is a cherry pie with a spider and a mouse."
    end

    it "parses duplicate replacements correctly" do
      survey = Survey.new thank_you_html: "This is a %pdq|cat% with a %pdq|dog%."
      hash = {"pdq" => "hat"}
      expect(survey.parsed_thank_you_html hash).to eq "This is a hat with a hat."
    end

    it "parses duplicate replacements with different defaults correctly" do
      survey = Survey.new thank_you_html: "This is a %pdq|cat% with a %pdq|dog%."
      hash = {}
      expect(survey.parsed_thank_you_html hash).to eq "This is a cat with a dog."
    end
  end
end
