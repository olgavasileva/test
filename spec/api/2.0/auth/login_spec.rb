require 'rails_helper'

describe :login do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/login", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(response.headers["Content-Type"]).to eq "application/json"}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  describe "Logging in with an email address" do
    context "With all required params" do
      let(:params) {{instance_token:instance_token, email:email, password:password}}

      context "With a valid email and password" do
        let(:email) {FactoryGirl.generate :email_address}
        let(:password) {FactoryGirl.generate :password}

        context "With an invalid instance" do
          let(:instance_token) {"INVALID"}

          it {expect(response.status).to eq 200}
          it {expect(response.headers["Content-Type"]).to eq "application/json"}
          it {expect(JSON.parse(response.body)).to_not be_nil}
          it {expect(JSON.parse(response.body)['error_code']).to eq 1001}
          it {expect(JSON.parse(response.body)['error_message']).to match /Invalid instance token/}
        end

        context "With a valid instance" do
          let(:instance) {FactoryGirl.create :instance}
          let(:instance_token) {instance.uuid}

          context "With both email and username" do
            let(:params) {{email:email, username:username, password:password, instance_token:instance_token}}
            let(:username) {FactoryGirl.generate :username}

            it {expect(response.status).to eq 200}
            it {expect(response.headers["Content-Type"]).to eq "application/json"}
            it {expect(JSON.parse(response.body)).to_not be_nil}
            it {expect(JSON.parse(response.body)['error_code']).to eq 400}
            it {expect(JSON.parse(response.body)['error_message']).to match /\[:email, :username\] are mutually exclusive/}
          end

          context "With neither email nor password " do
            let(:params) {{password:password, instance_token:instance_token}}

            it {expect(response.status).to eq 200}
            it {expect(response.headers["Content-Type"]).to eq "application/json"}
            it {expect(JSON.parse(response.body)).to_not be_nil}
            it {expect(JSON.parse(response.body)['error_code']).to eq 1006}
            it {expect(JSON.parse(response.body)['error_message']).to match /Neither email nor username supplied/}
          end

          context "When a user with the email doesn't already exist" do
            let (:email) {FactoryGirl.generate :email_address}

            it {expect(response.status).to eq 200}
            it {expect(response.headers["Content-Type"]).to eq "application/json"}
            it {expect(JSON.parse(response.body)).to_not be_nil}
            it {expect(JSON.parse(response.body)['error_code']).to eq 1004}
            it {expect(JSON.parse(response.body)['error_message']).to match /Email not found/}
          end

          context "When a user with the email adready exists" do
            let(:user) {FactoryGirl.create :user, password:password}
            let(:email) {user.email}

            context "When the password is incorrect" do
              let(:user) {FactoryGirl.create :user, password:"INCORRECT"}

              it {expect(response.status).to eq 200}
              it {expect(response.headers["Content-Type"]).to eq "application/json"}
              it {expect(JSON.parse(response.body)).to_not be_nil}
              it {expect(JSON.parse(response.body)['error_code']).to eq 1008}
              it {expect(JSON.parse(response.body)['error_message']).to match /Wrong password/}
            end

            context "When the instance already has an existing auth_token" do
              let(:instance) {FactoryGirl.create :instance, :authorized}

              it {expect(response.status).to eq 201}
              it {expect(response.headers["Content-Type"]).to eq "application/json"}
              it {expect(JSON.parse(response.body)).to_not be_nil}
              it {expect(JSON.parse(response.body)['error_code']).to be_nil}
              it {expect(JSON.parse(response.body)['error_message']).to be_nil}
              it {expect(JSON.parse(response.body)['auth_token']).to eq Instance.find_by(uuid:instance_token).auth_token}
              it {expect(JSON.parse(response.body)['email']).to eq user.email}
              it {expect(JSON.parse(response.body)['username']).to eq user.username}
              it "should change the auth_token" do
                expect(instance.auth_token).to_not eq Instance.find_by(uuid:instance_token).auth_token
              end
              it "The user should be tied to the instance" do
                instance = Instance.find_by uuid:instance_token
                expect(instance.user).to eq user
              end
            end

            context "When the instance doesn't have an auth_token" do
              let(:instance) {FactoryGirl.create :instance, :unauthorized}

              it {expect(response.status).to eq 201}
              it {expect(response.headers["Content-Type"]).to eq "application/json"}
              it {expect(JSON.parse(response.body)).to_not be_nil}
              it {expect(JSON.parse(response.body)['error_code']).to be_nil}
              it {expect(JSON.parse(response.body)['error_message']).to be_nil}
              it {expect(JSON.parse(response.body)['auth_token']).to eq Instance.find_by(uuid:instance_token).auth_token}
              it {expect(JSON.parse(response.body)['email']).to eq user.email}
              it {expect(JSON.parse(response.body)['username']).to eq user.username}
              it "The user should be tied to the instance" do
                instance = Instance.find_by uuid:instance_token
                expect(instance.user).to eq user
              end
            end
          end
        end
      end
    end
  end


  describe "Logging in with a username" do
    context "With all required params" do
      let(:params) {{instance_token:instance_token, username:username, password:password}}

      context "With a valid username and password" do
        let(:username) {FactoryGirl.generate :username}
        let(:password) {FactoryGirl.generate :password}

        context "When an inavlid instance token" do
          let(:instance_token) {"INVALID"}

          it {expect(response.status).to eq 200}
          it {expect(response.headers["Content-Type"]).to eq "application/json"}
          it {expect(JSON.parse(response.body)).to_not be_nil}
          it {expect(JSON.parse(response.body)['error_code']).to eq 1001}
          it {expect(JSON.parse(response.body)['error_message']).to match /Invalid instance token/}
        end

        context "With a valid instance" do
          let(:instance) {FactoryGirl.create :instance}
          let(:instance_token) {instance.uuid}

          context "When a user with the username doesn't already exist" do
            let (:username) {FactoryGirl.generate :username}

            it {expect(response.status).to eq 200}
            it {expect(response.headers["Content-Type"]).to eq "application/json"}
            it {expect(JSON.parse(response.body)).to_not be_nil}
            it {expect(JSON.parse(response.body)['error_code']).to eq 1005}
            it {expect(JSON.parse(response.body)['error_message']).to match /Handle not found/}
          end

          context "When a user with the username adready exists" do
            let(:user) {FactoryGirl.create :user, password:password}
            let(:username) {user.username}

            context "When the password is incorrect" do
              let(:user) {FactoryGirl.create :user, password:"INCORRECT"}

              it {expect(response.status).to eq 200}
              it {expect(response.headers["Content-Type"]).to eq "application/json"}
              it {expect(JSON.parse(response.body)).to_not be_nil}
              it {expect(JSON.parse(response.body)['error_code']).to eq 1008}
              it {expect(JSON.parse(response.body)['error_message']).to match /Wrong password/}
            end

            context "When the instance already has an existing auth_token" do
              let(:instance) {FactoryGirl.create :instance, :authorized}

              it {expect(response.status).to eq 201}
              it {expect(response.headers["Content-Type"]).to eq "application/json"}
              it {expect(JSON.parse(response.body)).to_not be_nil}
              it {expect(JSON.parse(response.body)['error_code']).to be_nil}
              it {expect(JSON.parse(response.body)['error_message']).to be_nil}
              it {expect(JSON.parse(response.body)['auth_token']).to eq Instance.find_by(uuid:instance_token).auth_token}
              it {expect(JSON.parse(response.body)['email']).to eq user.email}
              it {expect(JSON.parse(response.body)['username']).to eq user.username}
              it "should change the auth_token" do
                expect(instance.auth_token).to_not eq Instance.find_by(uuid:instance_token).auth_token
              end
              it "The user should be tied to the instance" do
                instance = Instance.find_by uuid:instance_token
                expect(instance.user).to eq user
              end
            end

            context "When the instance doesn't have an auth_token" do
              let(:instance) {FactoryGirl.create :instance, :unauthorized}

              it {expect(response.status).to eq 201}
              it {expect(response.headers["Content-Type"]).to eq "application/json"}
              it {expect(JSON.parse(response.body)).to_not be_nil}
              it {expect(JSON.parse(response.body)['error_code']).to be_nil}
              it {expect(JSON.parse(response.body)['error_message']).to be_nil}
              it {expect(JSON.parse(response.body)['auth_token']).to eq Instance.find_by(uuid:instance_token).auth_token}
              it {expect(JSON.parse(response.body)['email']).to eq user.email}
              it {expect(JSON.parse(response.body)['username']).to eq user.username}
              it "The user should be tied to the instance" do
                instance = Instance.find_by uuid:instance_token
                expect(instance.user).to eq user
              end
            end
          end
        end
      end
    end
  end
end