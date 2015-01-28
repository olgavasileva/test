require 'rails_helper'

describe 'POST /profile/headshot' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) { {
    auth_token: instance.auth_token,
    image_url: FactoryGirl.generate(:sample_image_url)
  } }
  let(:request) { -> { post 'v/2.0/profile/headshot', params }}

  it "creates a user avatar" do
    expect { request.call }.to change { UserAvatar.count }.by 1
  end

  it "updates current user's avatar" do
    expect { request.call }.to change { instance.user.reload.avatar }
  end

  it "responds with blank data" do
    request.call
    expect(JSON.parse(response.body)).to eq Hash.new
  end
end
