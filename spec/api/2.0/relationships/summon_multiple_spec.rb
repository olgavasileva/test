require 'rails_helper'

describe 'PUT /relationships/summon_multiple' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) { {
    auth_token: instance.user.auth_token,
    email_addresses: [FactoryGirl.generate(:email_address)],
    phone_numbers: ['555-123-4567']
  } }
  let(:response_body) { JSON.parse(response.body) }

  before { put 'v/2.0/relationships/summon_multiple', params }

  it "responds with blank data" do
    expect(response_body).to eq Hash.new
  end
end
