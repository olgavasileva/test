require 'rails_helper'

describe :promote_social do

  let(:user) { nil }
  let(:instance) { FactoryGirl.create(:instance, :logged_in, user: user) }

  let(:profile_valid) { true }


  let(:profile) do
    double('SocialProfile::FacebookAdapter', {
      valid?: true,
      name: 'Profile User',
      username: 'profileuser',
      email: 'profileuser@email.com',
      birthdate: '7/7/1985',
      provider: 'facebook',
      token: 'token',
      uid: '12345678',
      gender: 'female'
    })
  end

  let(:params) do
    {
      auth_token: instance.auth_token,
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

  context 'as a non-anonymous user' do
    let(:user) { FactoryGirl.create(:user) }
    include_examples :returns_error, 1012, "User must be anonymous"
  end

  context 'as an anonymous user' do
    let(:user) { FactoryGirl.create(:anonymous) }

    context 'with an invalid :provider_token' do
      before { allow(profile).to receive(:valid?).and_return(false) }
      include_examples :returns_error, 1002, "Could not access profile"
    end

    %i{email name username}.each do |attribute|
      context "with no decernable :#{attribute}" do
        before { allow(profile).to receive(attribute).and_return(nil) }
        include_examples :returns_error, 1003, "Profile has no #{attribute}"
      end
    end

    context 'when the users desired email exists' do
      let(:other) { FactoryGirl.create(:user) }
      before { params.merge!(email: other.email) }
      include_examples :returns_error, 1008, "email is already registered"
    end

    context 'when the users desired username exists' do
      let(:other) { FactoryGirl.create(:user) }
      before { params.merge!(username: other.username) }
      include_examples :returns_error, 1009, "username is already registered"
    end

    context 'when the user is under 13' do
      before { params.merge!(birthdate: '2015-01-01') }
      include_examples :returns_error, 1010, "must be over 13"
    end

    context 'when the user is invalid' do
      before { params.merge!(email: 'invalid') }
      include_examples :returns_error, 1011
    end

    context 'when the params are valid' do
      it 'updates the :auth_token' do
        expect{subject}.to change{instance.reload.auth_token}
      end

      it 'returns the correct :auth_token' do
        subject
        instance.reload
        expect(json['auth_token']).to eq(instance.auth_token)
      end

      it 'returns the correct :user_id' do
        subject
        expect(json['user_id']).to eq(user.id)
      end

      context 'and an Authentication record does not exist' do
        it 'creates an Authentication record' do
          expect{subject}.to change(Authentication, :count).by(1)
        end
      end
    end
  end
end
