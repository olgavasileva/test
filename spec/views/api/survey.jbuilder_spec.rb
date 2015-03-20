require 'rails_helper'

RSpec.describe 'views/api/survey.jbuilder' do

  before(:all) do
    @survey = FactoryGirl.create(:embeddable_survey)
    @unit = FactoryGirl.create(:embeddable_unit, survey: @survey)
  end

  after(:all) do
    @unit.destroy!
    @survey.destroy!
  end

  let(:survey) { @survey }

  before { allow(view).to receive(:current_user).and_return(User.new) }
  before { assign(:survey, survey) }
  before { render template: 'api/survey' }

  let(:json) { JSON.parse(rendered) }
  subject { json }

  it { is_expected.to have_json_key(:survey) }

  context 'the survey object' do
    subject { json['survey'] }

    it { is_expected.to have_json_key(:name).eq(survey.name) }
    it { is_expected.to have_json_key(:questions) }
    it { is_expected.to have_json_key(:embeddable_units) }
  end
end
