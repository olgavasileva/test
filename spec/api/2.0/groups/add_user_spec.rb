require 'rails_helper'

describe 'groups/add_user' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }
  let(:group) { FactoryGirl.create(:group, user: instance.user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:request) { -> { put 'v/2.0/groups/add_user', params } }

  shared_examples :fail do
    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end

  context "with valid params" do
    let(:params) { common_params.merge(id: group.id, user_id: user.id) }

    before do
      user.leaders << instance.user
      request.call
    end

    it "responds with blank data" do
      expect(response_body.keys).to match_array []
    end

    context "with group not belonging to current user" do
      let(:group) { FactoryGirl.create(:group) }

      include_examples :fail
    end

    context "with user not following current user" do
      let(:user2) { FactoryGirl.create(:user) }
      let(:params) { common_params.merge(id: group.id, user_id: user2.id) }

      include_examples :fail
    end

    context "with user not existing" do
      let(:params) { common_params.merge(id: group.id, user_id: -1) }

      include_examples :fail
    end
  end
end
