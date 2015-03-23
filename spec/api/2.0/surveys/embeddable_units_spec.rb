require 'rails_helper'

RSpec.describe TwoCents::Surveys, '/surveys/:survey_id/units' do
  before(:all) { @auth = FactoryGirl.create(:instance, :logged_in) }
  after(:all) { @auth.destroy! }

  let(:auth) { @auth }
  let(:survey) { FactoryGirl.create(:survey, user: auth.user) }

  describe 'POST /surveys/:survey_id/units' do
    let(:params) do
      {
        auth_token: auth.auth_token,
        embeddable_unit: {
          thank_you_markdown: '**Thanks**'
        }
      }
    end

    subject { post "v/2.0/surveys/#{survey.id}/units", params }

    it 'creates an EmbeddableUnit' do
      expect{subject}.to change(EmbeddableUnit, :count).by(1)
    end
  end

  describe 'GET /surveys/:survey_id/units/:uuid' do
    let(:unit) { FactoryGirl.create(:embeddable_unit, survey: survey) }
    let(:params) do
      {
        auth_token: auth.auth_token
      }
    end

    subject { get "v/2.0/surveys/#{survey.id}/units/#{unit.uuid}", params }

    it 'is successful' do
      subject
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json).to have_json_key(:embeddable_unit)
    end
  end

  describe 'PUT /surveys/:survey_id/units/:uuid' do
    let(:unit) { FactoryGirl.create(:embeddable_unit, survey: survey) }
    let(:params) do
      {
        auth_token: auth.auth_token,
        embeddable_unit: {thank_you_markdown: '**New Markdown**'}
      }
    end

    subject { put "v/2.0/surveys/#{survey.id}/units/#{unit.uuid}", params }

    it 'updates the unit' do
      expect{subject}.to change{unit.reload.thank_you_markdown}
    end
  end

  describe 'DELETE /surveys/:survey_id/units/:uuid' do
    let(:unit) { FactoryGirl.create(:embeddable_unit, survey: survey) }
    let(:params) do
      {
        auth_token: auth.auth_token,
      }
    end

    subject { delete "v/2.0/surveys/#{survey.id}/units/#{unit.uuid}", params }

    it 'deletes the unit' do
      subject
      expect(EmbeddableUnit.where(id: unit.id).exists?).to eq(false)
    end
  end
end
