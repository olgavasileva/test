require 'rails_helper'

RSpec.describe SurveysController do
  include Devise::TestHelpers

  before(:all) {
    @survey = FactoryGirl.create :survey, :embeddable
    @ad_unit = FactoryGirl.create :ad_unit
  }
  after(:all) { DatabaseCleaner.clean_with :truncation }

  let(:survey) { @survey }
  let(:ad_unit) { @ad_unit }
  let(:question) { survey.questions.to_a.shuffle.first }

  describe 'loading the Survey' do
    subject { get :start, survey_uuid: survey.uuid, unit_name: ad_unit.name }

    context 'given an invalid :survey_uuid' do
      let(:survey) { Survey.new(uuid: 'invalid') }
      it { is_expected.to render_template(:invalid_survey) }
    end

    context 'given a valid :survey_uuid' do
      context 'that is not authorized' do
        let(:survey) { FactoryGirl.create :survey }
        it { is_expected.to render_template(:invalid_survey) }
      end

      context 'that is authorized' do
        it { is_expected.to_not render_template(:invalid_survey) }
      end
    end
  end

  describe 'GET #start_survey' do
    subject { get :start, survey_uuid: survey.uuid, unit_name: ad_unit.name }

    it { is_expected.to render_template(:question) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(survey.questions.first)
    end
  end

  describe 'GET #question' do
    subject { get :question, survey_uuid: survey.uuid, unit_name: ad_unit.name, question_id: question.id }

    it { is_expected.to render_template(:question) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(question)
    end
  end

  describe 'POST #create_response' do
    let(:choice) { question.choices.to_a.shuffle.first }

    subject do
      post :create_response,
        survey_uuid: survey.uuid,
        unit_name: ad_unit.name,
        question_id: question.id,
        response: {choice_id: choice.id}
    end

    it { is_expected.to render_template(:question) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(question)
    end

    it 'creates a response correctly' do
      user = FactoryGirl.create(:user)
      allow(controller).to receive(:current_ad_unit_user) { user }

      expect{subject}.to change(Response, :count).by(1)
      response = assigns(:response)
      expect(response.question).to eq(question)
      expect(response.choice).to eq(choice)
      expect(response.user).to eq(user)
      expect(response.source).to eq('embeddable')
    end
  end

  describe 'GET #thank_you' do
    subject { get :thank_you, survey_uuid: survey.uuid, unit_name: ad_unit.name }
    it { is_expected.to render_template(:thank_you) }
  end

  describe '#POST quantcast' do
    before do
      allow_any_instance_of(DemographicObserver).to receive(:after_create)
        .and_return(nil)
    end

    let(:user) { FactoryGirl.create(:user) }
    let(:data) { JSON.dump(%w{D T 50086 50084 50082 50076 50075 50074 50072 50062 50060 50059 50058 50057 50056 50054}.map{|h|{id: h}}) }
    subject { post :quantcast, survey_uuid: survey.uuid, unit_name: ad_unit.name, quantcast: data }

    before { allow(controller).to receive(:current_ad_unit_user).and_return(user) }

    context 'when the user already has a demographic' do
      before { FactoryGirl.create :demographic, :quantcast, respondent: user }

      it 'does not create a Demographic' do
        expect{subject}.to_not change(Demographic, :count)
      end
    end

    context 'when the user does not have a demographic' do
      it 'creates a Demographic' do
        expect{subject}.to change(Demographic, :count).by(1)
      end
    end
  end

  describe '#current_ad_unit_user' do
    before do
      allow(controller).to receive(:cookies) { request.cookies }
      allow(request.cookies).to receive_messages(
        permanent: request.cookies,
        signed: request.cookies
      )
    end

    it 'remembers the current ad unit user' do
      ad_unit_user = controller.send(:current_ad_unit_user)
      expect(request.cookies[:eu_user_test][:value]).to eq(ad_unit_user.id)
    end

    context 'when no :eu_user cookie is present' do
      it 'creates an Anonymous user record' do
        expect {
          controller.send(:current_ad_unit_user)
        }.to change(Anonymous, :count).by(1)
      end
    end

    context 'when an :eu_user cookie is present' do
      let(:user) { FactoryGirl.create(:user) }
      before { request.cookies[:eu_user_test] = user.id }

      it 'does not create an Anonymous user record' do
        expect {
          controller.send(:current_ad_unit_user)
        }.to_not change(Anonymous, :count)
      end

      it 'loads the user from the :eu_user cookie' do
        ad_unit_user = controller.send(:current_ad_unit_user)
        expect(ad_unit_user).to eq(user)
      end
    end
  end
end
