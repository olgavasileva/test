require 'rails_helper'

RSpec.describe SocialProfile::TwitterAdapter do

  let(:token) { 'some_token' }
  let(:secret) { 'some_secret' }
  let(:adapter) { described_class.new(token, secret) }

  let(:id) { '12345678' }

  let(:profile) do
    Twitter::User.new({
      id: id,
      name: 'Test A User',
      screen_name: 'test_user'
    })
  end

  before { allow(adapter).to receive(:profile).and_return(profile) }

  describe '#provider' do
    subject { adapter.provider }
    it { should eq('twitter') }
  end

  describe '#valid?' do
    subject { adapter.valid? }
    context 'when no token is present' do
      let(:token) { nil }
      it { should eq(false) }
    end

    context 'when no secret is present' do
      let(:secret) { nil }
      it { should eq(false) }
    end

    context 'when no id is present' do
      let(:id) { nil }
      it { should eq(false) }
    end

    context 'when token, secret and id are present' do
      it { should eq(true) }
    end
  end

  describe '#uid' do
    subject { adapter.uid }
    it { should eq(id) }
  end

  describe '#first_name' do
    subject { adapter.first_name }
    it { should eq('Test') }
  end

  describe '#last_name' do
    subject { adapter.last_name }
    it { should eq('A User') }
  end

  describe '#name' do
    subject { adapter.name }
    it { should eq('Test A User') }
  end

  describe '#username' do
    subject { adapter.username }
    it { should eq('test_user') }
  end

  describe '#email' do
    subject { adapter.email }
    it { should eq(nil) }
  end

  describe '#gender' do
    subject { adapter.gender }
    it { should eq(nil) }
  end

  describe '#birthdate' do
    subject { adapter.birthdate }
    it { should eq(nil) }
  end
end
