require 'rails_helper'

describe 'GET /communities/trending' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:another_instance) { FactoryGirl.create(:instance, :logged_in) }

  let(:params) { {
      auth_token: instance.auth_token
  } }
  let!(:community) { FactoryGirl.create :community, user: another_instance.user, private: false }
  let!(:another_community) { FactoryGirl.create :community, user: another_instance.user, private: false }
  let!(:question) { FactoryGirl.create :question, user: another_instance.user }
  let!(:target) { FactoryGirl.create :consumer_target, user: another_instance.user, communities: [community], questions: [question] }

  it 'responds with communities' do
    get 'v/2.0/communities/trending', params
    expect(json.first['id']).to eq community.id
    expect(json.length).to eq 1
  end

  it 'not return communities where user a member' do
    get 'v/2.0/communities/trending', {auth_token: another_instance.auth_token }
    expect(json).to eq []
  end
end
