require 'rails_helper'

describe 'relationships/unfollow' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:user) { FactoryGirl.create(:user) }
  let(:params) { {
    auth_token: instance.auth_token,
    user_id: user.id
  } }
  let(:request) { -> { post 'v/2.0/relationships/unfollow', params } }
  let(:response_body) { JSON.parse(response.body) }

  describe "when following user" do
    before do
      instance.user.followers << user
      request.call
      instance.user.reload
    end

    it "unfollows user" do
      expect(instance.user.followers).to_not include user
    end
  end

  describe "when not following user" do
    before { request.call }

    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end
end
