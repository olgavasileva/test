require 'rails_helper'

describe 'POST /users/avatar' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:params) { {
    auth_token: instance.auth_token,
    image: FactoryGirl.generate(:image)
  } }
  let(:request) { -> { post 'v/2.0/users/avatar', params }}

  it "updates current user's avatar" do
    expect { request.call }.to change { instance.user.avatar.url }
  end

  it "responds with blank data" do
    request.call
    expect(JSON.parse(response.body)).to eq Hash.new
  end
end
