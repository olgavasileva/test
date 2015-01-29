require 'rails_helper'

describe 'DELETE groups/group' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }
  let(:request) { -> { delete 'v/2.0/groups/group', params } }

  context "with valid params" do
    let(:group) { FactoryGirl.create(:group, user: instance.user) }
    let(:params) { common_params.merge(id: group.id) }

    before { request.call }

    it "responds with blank data" do
      expect(response_body.keys).to match_array []
    end

    context "with group not belonging to user" do
      let(:group) { FactoryGirl.create(:group) }

      it "responds with error data" do
        expect(response_body.keys).to match_array %w[error_code error_message]
      end
    end
  end
end
