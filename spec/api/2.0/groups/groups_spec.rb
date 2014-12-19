require 'rails_helper'

describe 'groups/groups' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) { {
    auth_token: instance.user.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }

  before do
    FactoryGirl.create_list(:group, 3, user: instance.user)
    get 'v/2.0/groups/groups', params
  end

  it "responds with current user's groups data" do
    keys = %w[id name member_count]

    expect(response_body.count).to eq instance.user.groups.count
    expect(response_body.first.keys).to match_array(keys)
  end
end
