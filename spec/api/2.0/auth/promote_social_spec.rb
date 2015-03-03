require 'rails_helper'

RSpec.describe 'TwoCents::AuthApi#promote_social' do
  let(:provider_valid) { true }

  let(:profile) do
    double('SocialProfile::FacebookAdapter', {
      valid?: provider_valid,
      uid: 1234567,
      name: 'Profile User',
      provider: 'facebook',
      token: 'token',
      secret: 'secret'
    })
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:instance) { FactoryGirl.create(:instance, user: user) }

  let(:auth_user) { user }
  let!(:auth) do
    FactoryGirl.create(:authentication, :facebook, {
      user: auth_user,
      uid: profile.uid
    })
  end

  let(:params) do
    {
      instance_token: instance.uuid,
      provider: profile.provider,
      provider_token: profile.token
    }
  end

  before { allow(SocialProfile).to receive(:build).and_return(profile) }
  subject { post "v/2.0/users/promote_social", params }

  shared_examples_for :returns_error do |code, message=nil|
    before { subject }

    it "has the correct error code (#{code})" do
      expect(json['error_code']).to eq(code)
    end

    it "has the correct error message (#{message})" do
      expect(json['error_message']).to include(message)
    end if message
  end

  context 'for an invalid provider' do
    before { params.merge!(provider: 'invalid') }
    include_examples :returns_error, 1002, "Provider invalid: invalid"
  end

  context 'for invalid provider tokens' do
    let(:provider_valid) { false }
    include_examples :returns_error, 1003, "Could not access profile"
  end

  context 'when there is no user' do
    let(:user) { nil }
    include_examples :returns_error, 1004, "No user record can be determined"
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

  context 'as a registered user' do
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

  it 'updates the tracked fields for the user' do
    expect_any_instance_of(Respondent).to receive(:update_tracked_fields!)
      .with(kind_of(Grape::Request)).once

    subject
  end

  it 'updates instance#auth_token' do
    expect{subject}.to change{instance.reload.auth_token}
  end

  it 'renders the correct response' do
    subject
    instance.reload
    expect(json).to eq({
      'auth_token' => instance.auth_token,
      'email' => instance.user.email,
      'username' => instance.user.username,
      'user_id' => instance.user.id
    })
  end
end
