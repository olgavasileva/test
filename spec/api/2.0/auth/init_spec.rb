require 'rails_helper'

describe 'GET users/init' do
  let(:instance) { FactoryGirl.create :instance, :logged_in }
  let(:params) { {
    auth_token: instance.user.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }

  before { get 'v/2.0/users/init', params }

  it "responds with data with expected fields" do
    keys = %w[has_any_groups manages_any_communities]

    expect(response_body.keys).to match_array keys
  end
end
