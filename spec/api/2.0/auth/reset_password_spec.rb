require 'spec_helper'

describe :reset_password do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/reset_password/#{instance_token}", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With an invalid instance" do
    let(:instance_token) {"INVALID"}

    it {response.status.should eq 200}
    it {JSON.parse(response.body).should_not be_nil}
    it {JSON.parse(response.body)['error_code'].should eq 1001}
    it {JSON.parse(response.body)['error_message'].should match /Invalid instance token/}
  end

  context "With a valid instance" do
    let(:instance_token) {instance.uuid}
    let(:instance) {FactoryGirl.create :instance, user:user}

    context "When the instance has a user" do
      let(:user) {FactoryGirl.create :user}

      context "Without any params" do
        it {response.status.should eq 200}
        it {JSON.parse(response.body)['error_code'].should eq 1011}
        it {JSON.parse(response.body)['error_message'].should match /User not found/}
      end

      context "With a user's username" do
        let(:some_user) {FactoryGirl.create :user}
        let(:params) {{username:some_user.username}}

        it {response.status.should eq 201}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should be_nil}
        it {JSON.parse(response.body)['error_message'].should be_nil}
      end

      context "With a user's email address" do
        let(:some_user) {FactoryGirl.create :user}
        let(:params) {{email:some_user.email}}

        it {response.status.should eq 201}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should be_nil}
        it {JSON.parse(response.body)['error_message'].should be_nil}
      end

      context "With both email and username" do
        let(:some_user) {FactoryGirl.create :user}
        let(:params) {{email:some_user.email, username:some_user.username}}

        it {response.status.should eq 200}
        it {JSON.parse(response.body)['error_code'].should eq 400}
        it {JSON.parse(response.body)['error_message'].should match /\[:email, :username\] are mutually exclusive/}
      end
    end

    context "When the instance doesn't have a user" do
      let(:user) {nil}

      context "Without any params" do
        it {response.status.should eq 200}
        it {JSON.parse(response.body)['error_code'].should eq 1011}
        it {JSON.parse(response.body)['error_message'].should match /User not found/}
      end

      context "With a user's username" do
        let(:some_user) {FactoryGirl.create :user}
        let(:params) {{username:some_user.username}}

        it {response.status.should eq 201}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should be_nil}
        it {JSON.parse(response.body)['error_message'].should be_nil}
      end

      context "With a user's email address" do
        let(:some_user) {FactoryGirl.create :user}
        let(:params) {{email:some_user.email}}

        it {response.status.should eq 201}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should be_nil}
        it {JSON.parse(response.body)['error_message'].should be_nil}
      end

      context "With both email and username" do
        let(:some_user) {FactoryGirl.create :user}
        let(:params) {{email:some_user.email, username:some_user.username}}

        it {response.status.should eq 200}
        it {JSON.parse(response.body)['error_code'].should eq 400}
        it {JSON.parse(response.body)['error_message'].should match /\[:email, :username\] are mutually exclusive/}
      end
    end
  end
end