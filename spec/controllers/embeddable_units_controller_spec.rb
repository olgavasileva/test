require 'rails_helper'

RSpec.describe EmbeddableUnitsController do
  include Devise::TestHelpers

  before { @unit = FactoryGirl.create(:embeddable_unit) }

  let(:unit) { @unit }
  let(:question) { unit.questions.to_a.shuffle.first }

  describe 'loading the EmbeddableUnit' do
    subject { get :start_survey, embeddable_unit_uuid: unit.try(:uuid) }

    context 'given an invalid :embeddable_unit_uuid' do
      let(:unit) { EmbeddableUnit.new(uuid: 'invalid') }
      it { is_expected.to render_template(:invalid_unit) }
    end

    context 'given a valid :embeddable_unit_uuid' do
      context 'that is not authorized' do
        let(:unit) { EmbeddableUnit.create }
        it { is_expected.to render_template(:invalid_unit) }
      end

      context 'that is authorized' do
        it { is_expected.to_not render_template(:invalid_unit) }
      end
    end
  end

  describe 'GET #start_survey' do
    subject { get :start_survey, embeddable_unit_uuid: unit.uuid }

    it { is_expected.to render_template(:question) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(unit.questions.first)
    end
  end

  describe 'GET #survey_question' do
    subject { get :survey_question, embeddable_unit_uuid: unit.uuid, question_id: question.id }

    it { is_expected.to render_template(:question) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(question)
    end
  end

  describe 'POST #survey_response' do
    let(:choice) { question.choices.to_a.shuffle.first }

    subject do
      post :survey_response,
        embeddable_unit_uuid: unit.uuid,
        question_id: question.id,
        image_choice_response: {choice_id: choice.id}
    end

    it { is_expected.to render_template(:summary) }

    it 'assigns the question correctly' do
      subject
      expect(assigns(:question)).to eq(question)
    end

    it 'creates a response correctly' do
      user = FactoryGirl.create(:user)
      allow(controller).to receive(:current_embed_user) { user }

      expect{subject}.to change(Response, :count).by(1)
      response = assigns(:response)
      expect(response.question).to eq(question)
      expect(response.choice).to eq(choice)
      expect(response.user).to eq(user)
      expect(response.source).to eq('embeddable')
    end
  end

  describe 'GET #thank_you' do
    subject { get :thank_you, embeddable_unit_uuid: unit.uuid }
    it { is_expected.to render_template(:thank_you) }
  end

  describe '#POST quantcast' do
    before do
      allow_any_instance_of(DemographicObserver).to receive(:after_create)
        .and_return(nil)
    end

    let(:user) { FactoryGirl.create(:user) }
    let(:data) { JSON.dump(%w{D T 50086 50084 50082 50076 50075 50074 50072 50062 50060 50059 50058 50057 50056 50054}.map{|h|{id: h}}) }
    subject { post :quantcast, embeddable_unit_uuid: unit.uuid, quantcast: data }

    before { allow(controller).to receive(:current_embed_user).and_return(user) }

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

  describe '#current_embed_user' do
    before do
      allow(controller).to receive(:cookies) { request.cookies }
      allow(request.cookies).to receive_messages(
        permanent: request.cookies,
        signed: request.cookies
      )
    end

    it 'remembers the current embed user' do
      embed_user = controller.send(:current_embed_user)
      expect(request.cookies[:eu_user_test][:value]).to eq(embed_user.id)
    end

    context 'when no :eu_user cookie is present' do
      it 'creates an Anonymous user record' do
        expect {
          controller.send(:current_embed_user)
        }.to change(Anonymous, :count).by(1)
      end
    end

    context 'when an :eu_user cookies is present' do
      let(:user) { FactoryGirl.create(:user) }
      before { request.cookies[:eu_user_test] = user.id }

      it 'does not create an Anonymous user record' do
        expect {
          controller.send(:current_embed_user)
        }.to_not change(Anonymous, :count)
      end

      it 'loads the user from the :eu_user cookie' do
        embed_user = controller.send(:current_embed_user)
        expect(embed_user).to eq(user)
      end
    end
  end
end
