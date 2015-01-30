require 'rails_helper'

describe 'relationships/follow' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:user) { FactoryGirl.create(:user) }
  let(:params) { {
    auth_token: instance.auth_token,
    user_id: user.id
  } }
  let(:request) { -> { post 'v/2.0/relationships/follow', params } }
  let(:response_body) { JSON.parse(response.body) }

  describe "when not following user" do
    before { request.call }

    it "follows user" do
      expect(instance.user.leaders).to include(user)
    end
  end

  describe "when already following user" do
    before do
      instance.user.leaders << user
      request.call
    end

    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end
end
