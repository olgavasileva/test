require 'rails_helper'

RSpec.describe ApplicationController do
  include Devise::TestHelpers

  describe '#sign_in_through_auth_token' do
    let(:devise_user) { FactoryGirl.create(:user) }
    let(:instance) { nil }
    let(:auth_token) { instance.try(:auth_token) }

    controller do
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def index
        text = user_signed_in? ? current_user.id : 'no user'
        render text: text
      end
    end

    before { sign_in devise_user }
    before { get :index, auth_token: auth_token }

    context 'when no instance token is given' do
      it 'fallsback to the devise user' do
        expect(response.body).to eq(devise_user.id.to_s)
      end
    end

    context 'given an instance token' do
      context 'for an anonymous user' do
        let(:instance) { FactoryGirl.create(:instance, :anon) }

        it 'fallsback to the devise user' do
          expect(response.body).to eq(devise_user.id.to_s)
        end
      end

      context 'for a registered user' do
        let(:instance) { FactoryGirl.create(:instance, :logged_in) }

        it 'signs in the instance user' do
          expect(response.body).to eq(instance.user.id.to_s)
        end
      end
    end
  end
end
