require 'rails_helper'

RSpec.describe TwoCents::Surveys, '/surveys/:survey_id/questions' do
  before(:all) { @auth = FactoryGirl.create(:instance, :logged_in) }
  after(:all) { @auth.destroy! }

  let(:auth) { @auth }
  let(:params) { {auth_token: auth.auth_token} }
  let(:survey) { FactoryGirl.create(:survey, user: auth.user) }

  let(:question) { FactoryGirl.create(:question, user: auth.user) }

  describe 'POST /surveys/:survey_id/questions/:question_id' do

    subject { post "v/2.0/surveys/#{survey.id}/questions/#{question.id}", params }

    it 'returns a 204' do
      subject
      expect(response.status).to eq(204)
    end

    context 'when the relationship does not exist' do
      it 'adds the question to the survey' do
        expect{subject}.to change{survey.reload.questions.count}.by(1)
      end
    end

    context 'when the relationship exists' do
      before { QuestionsSurvey.create!(survey: survey, question: question) }

      it 'does create additional relationships' do
        expect{subject}.to_not change{survey.reload.questions.count}
      end
    end
  end

  describe 'DELETE /surveys/:survey_id/questions/:question_id' do

    subject { delete "v/2.0/surveys/#{survey.id}/questions/#{question.id}", params }

    it 'returns a 204' do
      subject
      expect(response.status).to eq(204)
    end

    context 'when the relationship does not exist' do
      it 'does not delete any relationships' do
        expect{subject}.to_not change{survey.reload.questions.count}
      end
    end

    context 'when the relationship exists' do
      before { QuestionsSurvey.create!(survey: survey, question: question) }

      it 'deletes the relationships' do
        expect{subject}.to change{survey.reload.questions.count}.by(-1)
      end
    end
  end
end
