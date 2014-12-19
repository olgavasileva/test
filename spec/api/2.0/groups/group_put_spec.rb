require 'rails_helper'

describe 'PUT groups/group' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.user.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }
  let(:request) { -> { put 'v/2.0/groups/group', params } }

  shared_examples :fail do
    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end

  context "with valid params" do
    let(:group) { FactoryGirl.create(:group, user: instance.user) }
    let(:params) { common_params.merge(id: group.id, name: group.name.reverse) }

    before { request.call }

    it "responds with blank data" do
      expect(response_body.keys).to match_array []
    end

    context "with group not belonging to user" do
      let(:group) { FactoryGirl.create(:group) }

      include_examples :fail
    end

    context "with group name matching existing user group name" do
      let(:group2) { FactoryGirl.create(:group, user: instance.user) }
      let(:params) { common_params.merge(id: group.id, name: group2.name) }

      include_examples :fail
    end
  end
end
