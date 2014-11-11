require 'rails_helper'
include Gravatarify::Base

describe 'GET /profile/headshot' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:params) { {
    auth_token: instance.auth_token,
    user_id: user_id
  } }
  let(:request) { -> { get 'v/2.0/profile/headshot', params }}
  before {request.call}

  context "With no user_id" do
    let(:user_id) {}

    context "When the user does not have a custom avatar" do
      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to be_nil}
      it {expect(JSON.parse(response.body)['error_message']).to be_nil}
      it {expect(JSON.parse(response.body)).not_to be_nil}

      it "returns the gravatar for the current_user's email address" do
        expect(JSON.parse(response.body)["avatar_url"]).to eq gravatar_url(instance.user.email, default: :identicon)
      end
    end

    context "When the user has a custom avatar" do
      let(:instance) { FactoryGirl.create(:instance, :authorized, user: avatar.user) }
      let(:avatar) { FactoryGirl.create :user_avatar }

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to be_nil}
      it {expect(JSON.parse(response.body)['error_message']).to be_nil}
      it {expect(JSON.parse(response.body)).not_to be_nil}

      it "returns the gravatar for the current_user's email address" do
        expect(JSON.parse(response.body)["avatar_url"]).to eq avatar.image.url
      end
    end
  end

  context "With the id of another user" do
    let(:user_id) {user.id}
    let(:user) {FactoryGirl.create :user}

    context "When the user does not have a custom avatar" do
      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to be_nil}
      it {expect(JSON.parse(response.body)['error_message']).to be_nil}
      it {expect(JSON.parse(response.body)).not_to be_nil}

      it "returns the avatar for the other user" do
        expect(JSON.parse(response.body)["avatar_url"]).to eq gravatar_url(user.email, default: :identicon)
      end
    end

    context "When the user has a custom avatar" do
      let(:avatar) { FactoryGirl.create :user_avatar }
      let(:user) {avatar.user}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to be_nil}
      it {expect(JSON.parse(response.body)['error_message']).to be_nil}
      it {expect(JSON.parse(response.body)).not_to be_nil}

      it "returns the gravatar for the current_user's email address" do
        expect(JSON.parse(response.body)["avatar_url"]).to eq avatar.image.url
      end
    end
  end
end
