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
end
