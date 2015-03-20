require 'rails_helper'

describe :profile do
  let(:auth) { FactoryGirl.create(:instance, :logged_in) }
  let(:auth_token) { auth.auth_token }
  let(:params) { {auth_token: auth_token} }

  subject { post "v/2.0/profile", params }

  context 'with an invalid :auth_token' do
    let(:auth_token) { "INVALID" }

    it 'returns the correct error' do
      subject
      expect(json['error_code']).to eq(402)
      expect(json['error_message']).to match(/Invalid auth token/)
    end
  end

  context 'given no :user_id' do
    it 'responds with the current_user' do
      subject
      expect(json['profile']['user_id']).to eq(auth.user.id)
    end
  end

  context 'given a :user_id param' do
    let(:user) { FactoryGirl.create(:user) }
    before { params.merge!(user_id: user.id) }

    it 'responds with the requested user' do
      subject
      expect(json['profile']['user_id']).to eq(user.id)
    end
  end
end
