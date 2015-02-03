require 'rails_helper'

RSpec.describe OmniauthController do

  shared_examples_for :is_not_successful do |message|
    it { should render_template(:callback) }

    it 'indicates auth was not succesful' do
      subject
      expect(assigns(:data)[:success]).to eq(false)
    end

    it 'indicates the error' do
      subject
      expect(assigns(:data)[:error]).to eq(message)
    end
  end

  describe '#failure' do
    subject { get :failure, message: 'Example error' }
    include_examples :is_not_successful, 'Example error'
  end

  describe '#callback' do
    let!(:instance) { nil }
    let(:instance_token) { instance.try(:uuid) }

    let(:auth_params) { {'instance_token' => instance_token} }
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        uid: '12345678',
        provider: 'facebook',
        credentials: {token: 'new-token', secret: 'new-secret'}
      })
    end

    before do
      allow(controller).to receive(:auth_hash) { auth_hash }
      allow(controller).to receive(:auth_params) { auth_params }
    end

    subject { get :callback, provider: 'facebook' }

    context 'without an instance token' do
      include_examples :is_not_successful, 'Instance token required'
    end

    context 'with an invalid instance token' do
      let(:instance_token) { 'invalid-token' }
      include_examples :is_not_successful, 'Instance token required'
    end

    context 'with a valid instance token' do
      let!(:instance) { FactoryGirl.create(:instance) }

      it { should render_template(:callback) }

      it 'indicates authentication was succesful' do
        subject
        expect(assigns(:data)[:success]).to eq(true)
      end

      it 'includes the authentication provider and token' do
        subject
        expect(assigns(:data)[:auth]).to eq({
          provider: auth_hash.provider,
          token: auth_hash.credentials.token
        })
      end
    end
  end
end
