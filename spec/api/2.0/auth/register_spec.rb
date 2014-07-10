require 'spec_helper'

describe :register do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/register/#{instance_token}", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

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

    context "With all required params" do
      let(:params) {{email:email, username:username, password:password, name:name}}

      let(:email) {FactoryGirl.generate :email_address}
      let(:username) {FactoryGirl.generate :username}
      let(:password) {FactoryGirl.generate :password}
      let(:name) {FactoryGirl.generate :name}

      it {response.status.should eq 201}
      it {JSON.parse(response.body).should_not be_nil}
      it {JSON.parse(response.body)['error_code'].should be_nil}
      it {JSON.parse(response.body)['error_message'].should be_nil}
      it "The user should be tied to the instance" do
        instance = Instance.find_by uuid:instance_token
        user = User.find_by email:email
        instance.user.should eq user
      end

      context "When the instance doesn't exist" do
        let(:instance_token) {"INVALID"}

        it {response.status.should eq 200}
        it {JSON.parse(response.body).should_not be_nil}
        it {JSON.parse(response.body)['error_code'].should eq 1001}
        it {JSON.parse(response.body)['error_message'].should match /Invalid instance token/}
      end

      context "When the instance exists" do
        context "When a user with the email adready exists" do
          let(:user) {FactoryGirl.create :user}
          let(:email) {user.email}

          it {response.status.should eq 200}
          it {JSON.parse(response.body).should_not be_nil}
          it {JSON.parse(response.body)['error_code'].should eq 1002}
          it {JSON.parse(response.body)['error_message'].should match /already registered/}
        end

        context "When a user with the username already exists" do
          let(:user) {FactoryGirl.create :user}
          let(:username) {user.username}

          it {response.status.should eq 200}
          it {JSON.parse(response.body).should_not be_nil}
          it {JSON.parse(response.body)['error_code'].should eq 1009}
          it {JSON.parse(response.body)['error_message'].should match /Handle is already taken/}
        end

        context "When a user with the email doesn't already exist" do
          it {response.status.should eq 201}
          it {JSON.parse(response.body).should_not be_nil}
          it {JSON.parse(response.body)['error_code'].should be_nil}
          it {JSON.parse(response.body)['error_message'].should be_nil}
          it {User.find_by(email:email).should_not be_nil}
          it {User.find_by(username:username.downcase).should_not be_nil}
          it {User.find_by(username:username.downcase).should eq User.find_by(email:email)}
          it {Instance.find_by(uuid:instance_token).user.id.should eq User.find_by(email:email).id}
          it {JSON.parse(response.body)['auth_token'].should eq Instance.find_by(uuid:instance_token).auth_token}

          it {User.find_by(email:email).name.should eq name}
          it "The user should be tied to the instance" do
            instance = Instance.find_by uuid:instance_token
            user = User.find_by email:email
            instance.user.should eq user
          end
        end
      end
    end
  end
end