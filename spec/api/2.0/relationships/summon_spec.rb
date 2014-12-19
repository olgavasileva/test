require 'rails_helper'

describe 'PUT /relationships/summon' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.user.auth_token,
  } }
  let(:other_params) { Hash.new }
  let(:params) { common_params.merge(other_params) }
  let(:request) { -> { put 'v/2.0/relationships/summon', params } }
  let(:response_body) { JSON.parse(response.body) }

  before { request.call }

  shared_examples :fail do
    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end

  shared_examples :success do
    it "responds with blank data" do
      expect(response_body.keys.count).to eq 0
    end
  end

  context "with email method" do
    let(:other_params) { { method: 'email' } }

    include_examples :fail

    context "with email_address" do
      let(:other_params) { { method: 'email', email_address: 'a@b.com' } }

      include_examples :success
    end
  end

  context "with sms method" do
    let(:other_params) { { method: 'sms' } }

    include_examples :fail

    context "with phone_number" do
      let(:other_params) { { method: 'sms', phone_number: '555-123-4567' } }

      include_examples :success
    end
  end
end
