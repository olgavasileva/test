require 'rails_helper'

describe 'GET /' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }

  let(:params) { common_params }
  before { get 'v/2.0/questions', params }

  it "responds successfully" do
    expect(response.status).to eq 200
    expect(response_body).to be_an Array
  end
end
