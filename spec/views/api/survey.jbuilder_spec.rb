require 'rails_helper'

RSpec.describe 'views/api/survey.jbuilder' do

  before(:all) { @survey = FactoryGirl.create(:survey) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:survey) { @survey }

  before { allow(view).to receive(:current_user).and_return(User.new) }
  before { assign(:survey, survey) }
  before { render template: 'api/survey' }

  let(:json) { JSON.parse(rendered) }
  subject { json }

  it { is_expected.to have_json_key(:survey) }

  context 'the survey object' do
    subject { json['survey'] }

    it { is_expected.to have_json_key(:id).eq(survey.id) }
    it { is_expected.to have_json_key(:name).eq(survey.name) }
    it { is_expected.to have_json_key(:thank_you_markdown)
          .eq(survey.thank_you_markdown) }
    it { is_expected.to have_json_key(:thank_you_html)
          .eq(survey.thank_you_html) }
    it { is_expected.to have_json_key(:user_id) }
    it { is_expected.to have_json_key(:questions) }
  end
end
