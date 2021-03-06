require 'rails_helper'

RSpec.describe TwoCents::Surveys, '/surveys' do
  before { @auth = FactoryGirl.create(:instance, :logged_in) }

  let(:auth) { @auth }

  describe 'POST /surveys' do
    let(:params) do
      {
        auth_token: auth.auth_token,
        name: 'Soda Pop Questions',
        redirect: 'none',
        redirect_url: 'https://google.com',
        redirect_timeout: 300,
        thank_you_markdown: '**Thank You**'
      }
    end

    subject { post 'v/2.0/surveys', params }

    it 'creates a Survey' do
      expect{subject}.to change(Survey, :count).by(1)
    end
  end

  describe 'GET /surveys/:survey_id' do
    let(:survey) { FactoryGirl.create(:survey, user: auth.user) }

    subject { get "v/2.0/surveys/#{survey.id}" }

    it 'is successful' do
      subject
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json).to have_json_key(:survey)
    end
  end

  describe 'PUT /surveys/:survey_id' do
    let(:survey) { FactoryGirl.create(:survey, user: auth.user) }

    let(:params) do
      {
        auth_token: auth.auth_token,
        name: SecureRandom.hex(10),
        theme_id: 2
      }
    end

    subject { put "v/2.0/surveys/#{survey.id}", params }

    it 'updates the Survey' do
      expect{subject}.to change{survey.reload.name}
      expect(survey.reload.theme_id).to eq 2
    end
  end

  describe 'DELETE /surveys/:survey_id' do
    let(:survey) { FactoryGirl.create(:survey, user: auth.user) }

    let(:params) { {auth_token: auth.auth_token} }

    subject { delete "v/2.0/surveys/#{survey.id}", params }

    it 'deletes the Survey' do
      subject
      expect(Survey.where(id: survey.id).exists?).to eq(false)
    end

    it 'returns a 204' do
      subject
      expect(response.status).to eq(204)
    end
  end
end
