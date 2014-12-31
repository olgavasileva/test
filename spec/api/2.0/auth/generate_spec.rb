require 'rails_helper'

describe 'POST s3_urls/generate' do
  let(:instance) { FactoryGirl.create :instance, :logged_in }
  let(:params) { {
      auth_token: instance.user.auth_token,
      upload_count: [1, 2, 3, 4].sample
  } }
  let(:response_body) { JSON.parse(response.body) }

  before { post "v/2.0/s3_urls/generate", params }

  it "responds with array of hashes which contain necessary keys" do
    keys = %w[url AWSAccessKeyId key policy signature success_action_status acl Content-Type]

    expect(response_body.sample.keys).to match_array keys
  end

  it "responds with an array of objects which equal upload_count" do
    expect(response_body.count).to eq(params[:upload_count])
  end
end
