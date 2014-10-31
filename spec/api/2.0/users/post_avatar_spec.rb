require 'rails_helper'

describe 'POST /users/avatar' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:params) { {
    auth_token: instance.auth_token,
    image_url: FactoryGirl.generate(:sample_image_url)
  } }
  let(:request) { -> { post 'v/2.0/users/avatar', params }}

  it "creates a user avatar" do
    expect { request.call }.to change { UserAvatar.count }.by 1
  end

  it "updates current user's avatar" do
    expect { request.call }.to change { instance.user.reload.user_avatar }
  end

  it "responds with blank data" do
    request.call
    expect(JSON.parse(response.body)).to eq Hash.new
  end
end
