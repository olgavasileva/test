require 'spec_helper'

describe :login do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/login/#{instance_token}", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With an invalid instance" do
    let(:instance_token) {"INVALID"}

    it {response.status.should eq 200}
    it {JSON.parse(response.body).should_not be_nil}
    it {JSON.parse(response.body)['error_code'].should eq 400}
    it {JSON.parse(response.body)['error_message'].should match /.+ is missing/}
  end

  context "With a valid instance" do
    let(:instance) {FactoryGirl.create :instance}
    let(:instance_token) {instance.uuid}

    context "With a valid email and password" do
      let(:params) {{email:email, password:password}}

      let(:email) {FactoryGirl.generate :email_address}
      let(:password) {FactoryGirl.generate :password}

      context "With both email and username" do
        let(:params) {{email:email, username:username, password:password}}
        let(:username) {FactoryGirl.generate :username}

        it {response.status.should eq 200}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should eq 400}
        it {JSON.parse(response.body)['error_message'].should match /\[:email, :username\] are mutually exclusive/}
      end

      context "With neither email nor password " do
        let(:params) {{password:password}}

        it {response.status.should eq 200}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should eq 1006}
        it {JSON.parse(response.body)['error_message'].should match /Neither email nor username supplied/}
      end

      context "When the instance doesn't exist" do
        let(:instance_token) {"INVALID"}

        it {response.status.should eq 200}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should eq 1001}
        it {JSON.parse(response.body)['error_message'].should match /Invalid instance token/}
      end

      context "When the instance exists" do
        context "When a user with the email doesn't already exist" do
          let (:email) {FactoryGirl.generate :email_address}

          it {response.status.should eq 200}
          it {JSON.parse(response.body).should_not be_nil}
          it {JSON.parse(response.body)['error_code'].should eq 1004}
          it {JSON.parse(response.body)['error_message'].should match /Email not found/}
        end

        context "When a user with the email adready exists" do
          let(:user) {FactoryGirl.create :user, password:password}
          let(:email) {user.email}

          context "When the password is incorrect" do
            let(:user) {FactoryGirl.create :user, password:"INCORRECT"}

            it {response.status.should eq 200}
            it {JSON.parse(response.body).should_not be_nil}
            it {JSON.parse(response.body)['error_code'].should eq 1008}
            it {JSON.parse(response.body)['error_message'].should match /Wrong password/}
          end

          context "When the instance already has an existing auth_token" do
            let(:instance) {FactoryGirl.create :instance, :authorized}

            it {response.status.should eq 201}
            it {JSON.parse(response.body).should_not be_nil}
            it {JSON.parse(response.body)['error_code'].should be_nil}
            it {JSON.parse(response.body)['error_message'].should be_nil}
            it {JSON.parse(response.body)['auth_token'].should eq Instance.find_by(uuid:instance_token).auth_token}
            it {JSON.parse(response.body)['email'].should eq user.email}
            it {JSON.parse(response.body)['username'].should eq user.username}
            it "should change the auth_token" do
              instance.auth_token.should_not eq Instance.find_by(uuid:instance_token).auth_token
            end
            it "The user should be tied to the instance" do
              instance = Instance.find_by uuid:instance_token
              instance.user.should eq user
            end
          end

          context "When the instance doesn't have an auth_token" do
            let(:instance) {FactoryGirl.create :instance, :unauthorized}

            it {response.status.should eq 201}
            it {JSON.parse(response.body).should_not be_nil}
            it {JSON.parse(response.body)['error_code'].should be_nil}
            it {JSON.parse(response.body)['error_message'].should be_nil}
            it {JSON.parse(response.body)['auth_token'].should eq Instance.find_by(uuid:instance_token).auth_token}
            it {JSON.parse(response.body)['email'].should eq user.email}
            it {JSON.parse(response.body)['username'].should eq user.username}
            it "The user should be tied to the instance" do
              instance = Instance.find_by uuid:instance_token
              instance.user.should eq user
            end
          end
        end
      end
    end

    context "With a valid username and password" do
      let(:params) {{username:username, password:password}}

      let(:username) {FactoryGirl.generate :username}
      let(:password) {FactoryGirl.generate :password}

      context "When the instance doesn't exist" do
        let(:instance_token) {"INVALID"}

        it {response.status.should eq 200}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should eq 1001}
        it {JSON.parse(response.body)['error_message'].should match /Invalid instance token/}
      end

      context "When the instance exists" do
        context "When a user with the username doesn't already exist" do
          let (:username) {FactoryGirl.generate :username}

          it {response.status.should eq 200}
          it {JSON.parse(response.body).should_not be_nil}
          it {JSON.parse(response.body)['error_code'].should eq 1005}
          it {JSON.parse(response.body)['error_message'].should match /Handle not found/}
        end

        context "When a user with the username adready exists" do
          let(:user) {FactoryGirl.create :user, password:password}
          let(:username) {user.username}

          context "When the password is incorrect" do
            let(:user) {FactoryGirl.create :user, password:"INCORRECT"}

            it {response.status.should eq 200}
            it {JSON.parse(response.body).should_not be_nil}
            it {JSON.parse(response.body)['error_code'].should eq 1008}
            it {JSON.parse(response.body)['error_message'].should match /Wrong password/}
          end

          context "When the instance already has an existing auth_token" do
            let(:instance) {FactoryGirl.create :instance, :authorized}

            it {response.status.should eq 201}
            it {JSON.parse(response.body).should_not be_nil}
            it {JSON.parse(response.body)['error_code'].should be_nil}
            it {JSON.parse(response.body)['error_message'].should be_nil}
            it {JSON.parse(response.body)['auth_token'].should eq Instance.find_by(uuid:instance_token).auth_token}
            it {JSON.parse(response.body)['email'].should eq user.email}
            it {JSON.parse(response.body)['username'].should eq user.username}
            it "should change the auth_token" do
              instance.auth_token.should_not eq Instance.find_by(uuid:instance_token).auth_token
            end
            it "The user should be tied to the instance" do
              instance = Instance.find_by uuid:instance_token
              instance.user.should eq user
            end
          end

          context "When the instance doesn't have an auth_token" do
            let(:instance) {FactoryGirl.create :instance, :unauthorized}

            it {response.status.should eq 201}
            it {JSON.parse(response.body).should_not be_nil}
            it {JSON.parse(response.body)['error_code'].should be_nil}
            it {JSON.parse(response.body)['error_message'].should be_nil}
            it {JSON.parse(response.body)['auth_token'].should eq Instance.find_by(uuid:instance_token).auth_token}
            it {JSON.parse(response.body)['email'].should eq user.email}
            it {JSON.parse(response.body)['username'].should eq user.username}
            it "The user should be tied to the instance" do
              instance = Instance.find_by uuid:instance_token
              instance.user.should eq user
            end
          end
        end
      end
    end
  end
end