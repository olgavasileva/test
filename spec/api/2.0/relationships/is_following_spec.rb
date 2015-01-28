require 'rails_helper'

describe 'relationships/is_following' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:user) { FactoryGirl.create(:user) }
  let(:params) { {
    auth_token: instance.auth_token,
    user_id: user.id
  } }
  let(:request) { -> { get 'v/2.0/relationships/is_following', params } }

  context "when not following" do
    before { request.call }

    it { expect(response.body).to eq 'false' }
  end

  context "when following" do
    before do
      instance.user.leaders << user
      request.call
    end

    it { expect(response.body).to eq 'true' }
  end
end
