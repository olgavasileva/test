require 'rails_helper'

RSpec.describe OmniauthController do

  let(:cookie_name) { controller.send(:provider_cookie_name) }
  let(:cookie_domain) { controller.send(:provider_cookie_domain) }
  let(:cookie) { JSON.parse(response.cookies[cookie_name]) }

  shared_examples_for :is_not_successful do |message|
    it { should render_template(:callback) }

    it 'indicates auth was not succesful' do
      subject
      expect(cookie['success']).to eq(false)
    end

    it 'indicates provider is invalid' do
      subject
      expect(cookie['provider_valid']).to eq(false)
    end

    it 'indicates the correct error' do
      subject
      expect(cookie['error']).to eq(message)
    end
  end

  describe '#setup' do
    it 'deletes the cookie' do
      response.cookies[cookie_name] = 'anything'
      get :setup, provider: 'facebook'
      expect(response.cookies[cookie_name]).to eq(nil)
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
        info: {name: 'Test User', email: nil},
        credentials: {token: 'new-token', secret: 'new-secret'}
      })
    end

    before do
      allow(controller).to receive(:auth_hash) { auth_hash }
      allow(controller).to receive(:auth_params) { auth_params }
    end

    subject { get :callback, provider: 'facebook' }

    context 'without an instance token' do
      include_examples :is_not_successful, I18n.t('omniauth.error.instance_required')
    end

    context 'with an invalid instance token' do
      let(:instance_token) { 'invalid-token' }
      include_examples :is_not_successful, I18n.t('omniauth.error.instance_required')
    end

    context 'without a user for the Authentication or Instance' do
      let!(:instance) { FactoryGirl.create(:instance) }

      it 'sets the correct data' do
        subject
        auth = Authentication.find_by({
          provider: auth_hash.provider,
          uid: auth_hash.uid
        })

        expect(cookie).to eq({
          'success' => false,
          'provider_valid' => true,
          'provider_id' => auth.id
        })
      end
    end

    context 'with a valid instance token' do
      let(:user) { FactoryGirl.create(:user) }
      let!(:instance) { FactoryGirl.create(:instance, user: user) }

      let(:auth_user) { user }
      let!(:auth) do
        FactoryGirl.create(:authentication, :facebook, {
          user: auth_user,
          uid: auth_hash.uid
        })
      end

      it { should render_template(:callback) }

      it 'updates instance#auth_token' do
        expect{subject}.to change{instance.reload.auth_token}
      end

      it 'class #update_tracked_fields! on the user' do
        expect_any_instance_of(Respondent).to receive(:update_tracked_fields!)
          .with(request).once

        subject
      end

      it 'sets the correct data' do
        subject
        expect(cookie).to eq({
          'success' => true,
          'provider_valid' => true,
          'provider_id' => auth.id,
          'auth_token' => instance.reload.auth_token,
          'email' => instance.user.email,
          'username' => instance.user.username,
          'user_id' => instance.user.id,
          'providers' => [{'id' => auth.id, 'provider' => auth.provider}]
        })
      end

      context 'when an ActiveRecord::ActiveRecordError is raised' do
        before do
          allow_any_instance_of(Authentication).to receive(:save!)
            .and_raise(ActiveRecord::ActiveRecordError)
        end

        include_examples :is_not_successful, I18n.t('omniauth.error.process_error')
      end

      context 'as an Anonymous user' do
        let(:user) { FactoryGirl.create(:anonymous) }

        context 'when the Authentication user is missing' do
          let(:auth_user) { nil }

          it 'promotes the user and sets it as authentication#user' do
            subject
            expected_user = User.find(user.id)
            expect(expected_user).to be_a(User)
            expect(Authentication.find(auth.id).user).to eq(expected_user)
          end
        end

        context 'when the Authentication user is present' do
          let(:auth_user) { FactoryGirl.create(:user) }

          it 'sets the user of instance as Authentication#user' do
            subject
            expect(instance.reload.user).to eq(auth_user)
          end
        end
      end

      context 'as a registered User' do

        context 'when the instance has a user' do
          it 'sets the authentication#user to the instance#user' do
            subject
            expect(auth.reload.user).to eq(user)
          end
        end

        context 'when the instance does not have a user' do
          let(:instance) { FactoryGirl.create(:instance) }

          it 'sets the instance#user to the authentication#user' do
            subject
            expect(instance.reload.user).to eq(auth_user)
          end
        end
      end
    end
  end
end
