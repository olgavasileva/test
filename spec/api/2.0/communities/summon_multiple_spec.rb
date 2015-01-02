require 'rails_helper'

describe 'PUT /communities/summon_multiple' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) { {
    auth_token: instance.user.auth_token,
    email_addresses: [FactoryGirl.generate(:email_address)],
    phone_numbers: ['555-123-4567'],
    community_id: community_id
  } }
  let(:response_body) { JSON.parse(response.body) }
  let(:community) { FactoryGirl.create :community}
  let(:community_id) { community.id}

  before {allow(Setting).to receive(:find_by_key).and_return(Setting.new(value:"Some String"))}
  before { put 'v/2.0/communities/summon_multiple', params }

  it "responds with blank data" do
    expect(response_body).to eq Hash.new
  end
end
