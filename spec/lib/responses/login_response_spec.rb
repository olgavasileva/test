require 'rails_helper'

RSpec.describe LoginResponse do

  describe '.respond_with' do
    it 'takes an Instance and Authentication and returns a Hash' do
      instance = Instance.new
      auth = Authentication.new

      response = LoginResponse.respond_with(instance, auth)
      expect(response).to be_a(Hash)
    end
  end

  shared_examples_for :includes_instance do |positive=true|
    desc = positive ? 'includes' : 'does not include'
    to_matcher = positive ? 'to' : 'to_not'
    it "#{desc} Instance attributes" do
      expect(subject.keys).send(
        to_matcher,
        include(:auth_token, :user_id, :username, :email)
      )
    end
  end

  shared_examples_for :includes_auth do
    it 'includes Authentication attributes' do
      expect(subject.keys).to include(:auth_token, :user_id, :username, :email)
    end
  end

  describe '#user' do
    it 'returns instance.user' do
      instance = Instance.new(user: User.new)
      response = LoginResponse.new(instance)
      expect(response.user).to eq(instance.user)
    end
  end

  describe '#to_hash' do
    let(:user) { User.new }
    let(:instance) { Instance.new(user: user) }
    let(:auth) { Authentication.new(user: user) }

    let(:response) { LoginResponse.new(instance, auth) }
    subject { response.to_hash }

    context 'given an Instance with a user' do
      include_examples :includes_instance
    end

    context 'given an Instance with no user' do
      let(:user) { nil }
      include_examples :includes_instance, false
    end

    context 'given an Authentication with a user' do
      include_examples :includes_auth
    end

    context 'given an Authentication with no user' do
      include_examples :includes_auth, false
    end

    context 'it returns the correct attributes' do
      let(:instance) { create(:instance, :logged_in) }
      let(:user) { instance.user}
    end
  end

  describe '#to_json' do
    it 'delegates to #to_hash' do
      hash = {test: 1}
      response = LoginResponse.new(Instance.new)

      expect(response).to receive(:to_hash).and_return(hash)
      expect(response.to_json).to eq(hash.to_json)
    end
  end

  describe '#as_json' do
    it 'delegates to #to_hash' do
      hash = {test: 1}
      response = LoginResponse.new(Instance.new)

      expect(response).to receive(:to_hash).and_return(hash)
      expect(response.as_json).to eq(hash.as_json)
    end
  end
end
