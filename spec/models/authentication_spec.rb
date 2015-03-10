require 'rails_helper'

RSpec.describe Authentication do

  it { should belong_to(:user) }

  describe 'validations' do
    it { should validate_presence_of(:provider) }
    it { should validate_inclusion_of(:provider).in_array(Authentication::PROVIDERS) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:token) }

    describe 'for unique attributes' do
      before { FactoryGirl.create(:authentication) }
      it { should validate_uniqueness_of(:uid).scoped_to(:provider) }
    end
  end

  describe '.from_provider_id' do
    it 'queries for the record correctly' do
      expect(Authentication).to receive(:where)
        .with({provider: 'test', uid: 1}).ordered { Authentication }

      expect(Authentication).to receive(:first_or_initialize).ordered

      Authentication.from_provider_id('test', 1)
    end
  end

  describe '.from_social_profile' do
    let(:profile) { double('SocialProfile::BaseAdapter', {
      provider: 'facebook',
      uid: 1,
      token: 'token',
      secret: 'secret'
    }) }

    it 'delegates to .from_provider_id' do
      expect(Authentication).to receive(:from_provider_id)
        .with('facebook', 1).and_call_original

      Authentication.from_social_profile(profile)
    end

    it 'sets the :token' do
      auth = Authentication.from_social_profile(profile)
      expect(auth.token).to eq(profile.token)
    end

    it 'sets the :secret when present' do
      auth = Authentication.from_social_profile(profile)
      expect(auth.token_secret).to eq(profile.secret)
    end

    it 'does not set the :secret when none is present' do
      FactoryGirl.create(:authentication, :facebook, uid: 1, token_secret: 'test_secret')
      allow(profile).to receive(:secret) { nil }
      auth = Authentication.from_social_profile(profile)
      expect(auth.token_secret).to eq('test_secret')
    end
  end

  describe '.from_omniauth' do
    let(:hash) do
      OmniAuth::AuthHash.new({
        uid: '12345678',
        provider: 'facebook',
        credentials: {token: 'new-token', secret: 'new-secret'}
      })
    end

    it 'delegates to .from_provider_id' do
      expect(Authentication).to receive(:from_provider_id)
        .with(hash.provider, hash.uid).and_call_original

      Authentication.from_omniauth(hash)
    end

    it 'sets the :token' do
      auth = Authentication.from_omniauth(hash)
      expect(auth.token).to eq(hash.credentials.token)
    end

    it 'sets the :token_secret' do
      auth = Authentication.from_omniauth(hash)
      expect(auth.token_secret).to eq(hash.credentials.secret)
    end
  end
end
