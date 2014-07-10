require 'spec_helper'

describe :logout do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/logout/#{instance_token}", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With an invalid instance" do
    let(:instance_token) {"INVALID"}

    it {response.status.should eq 200}
    it {JSON.parse(response.body).should_not be_nil}
    it {JSON.parse(response.body)['error_code'].should eq 1001}
    it {JSON.parse(response.body)['error_message'].should match /Invalid instance token/}
  end

  context "With a valid instance" do
    let(:instance_token) {instance.uuid}

    context "When the instance is authorized and logged in" do
      let(:instance) {FactoryGirl.create :instance, :authorized, :logged_in}

      it {response.status.should eq 201}
      it {JSON.parse(response.body).should_not be_nil}
      it {JSON.parse(response.body)['error_code'].should be_nil}
      it {JSON.parse(response.body)['error_message'].should be_nil}
      it {instance.reload.auth_token.should be_nil}
      it {instance.reload.user.should be_nil}
    end

    context "When the instance is unauthorized and logged in" do
      let(:instance) {FactoryGirl.create :instance, :unauthorized, :logged_in}

      it {response.status.should eq 201}
      it {JSON.parse(response.body).should_not be_nil}
      it {JSON.parse(response.body)['error_code'].should be_nil}
      it {JSON.parse(response.body)['error_message'].should be_nil}
      it {instance.reload.auth_token.should be_nil}
      it {instance.reload.user.should be_nil}
    end
  end
end