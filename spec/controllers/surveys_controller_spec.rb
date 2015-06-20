require 'rails_helper'

RSpec.describe SurveysController do
  include Devise::TestHelpers

  before {
    @survey = FactoryGirl.create :survey, :embeddable
    @ad_unit = FactoryGirl.create :ad_unit
  }

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

  describe 'GET #start' do
    subject { get :start, survey_uuid: survey.uuid, unit_name: ad_unit.name }

    it { is_expected.to render_template(:start) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(survey.questions.first)
    end

    it 'assigns the thank_you html correctly' do
      subject
      expect(assigns(:thank_you_html)).to eq survey.parsed_thank_you_html({})
    end

    context "When the http referrer is set" do
      before { @request.env['HTTP_REFERER'] = "some/path" }
      it 'assigns the @original_referrer correctly' do
        subject
        expect(assigns(:original_referrer)).to eq "some/path"
      end
    end
  end

  describe 'GET #question' do
    subject { get :question, survey_uuid: survey.uuid, unit_name: ad_unit.name, question_id: question.id, original_referrer: original_referrer }
    let(:original_referrer) { nil }

    it { is_expected.to render_template(:question) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(question)
    end

    context "When the session has a response for the question" do
      let(:response) { FactoryGirl.create :image_choice_response, question: question, original_referrer: original_referrer }
      before { expect_any_instance_of(SurveysController).to receive(:session_response_for_question).with(question).and_return(response) }

      it 'assigns the response correctly' do
        subject
        expect(assigns(:response)).to eq(response)
      end

      context "When the original_referrer is set on the response" do
        let(:original_referrer) { "test/referrer" }

        it 'assigns the original_referrer correctly' do
          subject
          expect(assigns(:original_referrer)).to eq "test/referrer"
        end
      end
    end
  end

  describe 'POST #create_response' do
    let(:choice) { question.choices.to_a.shuffle.first }
    let(:original_referrer) {}

    subject do
      post :create_response,
        survey_uuid: survey.uuid,
        unit_name: ad_unit.name,
        question_id: question.id,
        response: {choice_id: choice.id, original_referrer: original_referrer}
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

    it 'remembers the response in the session' do
      expect_any_instance_of(SurveysController).to receive(:remember_session_response)
      subject
    end

    context "When the original_referrer is set" do
      let(:original_referrer) { "original/referrer" }

      it 'creates a response with the original referrer' do
        expect{subject}.to change(Response, :count).by(1)
        expect(assigns(:response).original_referrer).to eq "original/referrer"
      end

      it 'sets the original_referrer correctly' do
        subject
        expect(assigns(:original_referrer)).to eq "original/referrer"
      end
    end
  end

  describe 'GET #thank_you' do
    subject { get :thank_you, survey_uuid: survey.uuid, unit_name: ad_unit.name }
    it { is_expected.to render_template(:thank_you) }
    it "shoud clear the session responses" do
      expect_any_instance_of(SurveysController).to receive(:reset_session_responses)
      subject
    end
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
