require 'rails_helper'

describe 'groups/remove_user' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.user.auth_token
  } }
  let(:response_body) { JSON.parse(response.body) }
  let(:group) { FactoryGirl.create(:group, user: instance.user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:request) { -> { put 'v/2.0/groups/remove_user', params } }

  shared_examples :fail do
    it "responds with error data" do
      request.call
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end

  shared_examples :success do
    it "responds with blank data" do
      request.call
      expect(response_body.keys).to match_array []
    end
  end

  let(:params) { common_params.merge(id: group.id, user_id: user.id) }

  include_examples :fail

  context "with user following current user" do
    before { instance.user.followers << user }

    include_examples :fail

    context "with user in group" do
      before do
        member = GroupMember.new user_id: user.id, group_id: group.id
        member.save! validate: false
      end

      include_examples :success

      context "with group not belonging to current user" do
        let(:group) { FactoryGirl.create(:group) }

        include_examples :fail
      end
    end
  end

  context "with user not existing" do
    let(:params) { common_params.merge(id: group.id, user_id: -1) }

    include_examples :fail
  end
end
