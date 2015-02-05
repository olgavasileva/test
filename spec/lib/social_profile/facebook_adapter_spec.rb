require 'rails_helper'

RSpec.describe SocialProfile::FacebookAdapter do

  let(:token) { 'some_token' }
  let(:adapter) { described_class.new(token) }

  let(:profile) do
    {
      'id' => '12345678',
      'first_name' => 'Test',
      'last_name' => 'User',
      'email' => 'testuser@email.com',
      'gender' => 'female',
      'birthday' => '7/7/1985'
    }
  end

  before { allow(adapter).to receive(:profile).and_return(profile) }

  describe '#provider' do
    subject { adapter.provider }
    it { should eq('facebook') }
  end

  describe '#valid?' do
    subject { adapter.valid? }
    context 'when no token is present' do
      let(:token) { nil }
      it { should eq(false) }
    end

    context 'when a token is present' do
      context 'and the profile is empty' do
        let(:profile) { {} }
        it { should eq(false) }
      end

      context 'and the profile is not empty' do
        it { should eq(true) }
      end
    end
  end

  describe '#uid' do
    subject { adapter.uid }
    it { should eq('12345678') }
  end

  describe '#first_name' do
    subject { adapter.first_name }
    it { should eq('Test') }
  end

  describe '#last_name' do
    subject { adapter.first_name }
    it { should eq('Test') }
  end

  describe '#name' do
    subject { adapter.name }
    it { should eq('Test User') }
  end

  describe '#username' do
    subject { adapter.username }
    it { should eq('testuser') }
  end

  describe '#email' do
    subject { adapter.email }
    it { should eq('testuser@email.com') }
  end

  describe '#gender' do
    subject { adapter.gender }
    it { should eq('female') }

    context 'when neither male nor female' do
      before { profile.merge!('gender' => 'monkey') }
      it { should eq(nil) }
    end
  end

  describe '#birthdate' do
    subject { adapter.birthdate }
    it { should eq('7/7/1985') }
  end
end
