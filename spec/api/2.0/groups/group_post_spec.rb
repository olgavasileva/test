require 'rails_helper'

describe 'POST groups/group' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) { {
    auth_token: instance.user.auth_token,
    name: "Testers"
  } }
  let(:response_body) { JSON.parse(response.body) }
  let(:request) { -> { post 'v/2.0/groups/group', params } }

  before { request.call }

  context "with valid params" do
    it "responds with group data" do
      expect(response_body.keys).to match_array %w[id name]
    end

    context "with existing group with user and name" do
      before { request.call }

      it "responds with error data" do
        expect(response_body.keys).to match_array %w[error_code error_message]
      end
    end
  end
end
