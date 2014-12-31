require 'rails_helper'

describe :register do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/register", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(json).to_not be_nil}
    it {expect(json['error_code']).to eq 400}
    it {expect(json['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{instance_token:instance_token, email:email, username:username, password:password, name:name, birthdate:birthdate, gender:gender}}

    context "With valid email, username, password, and name params" do
      let(:email) {FactoryGirl.generate :email_address}
      let(:username) {FactoryGirl.generate :username}
      let(:password) {FactoryGirl.generate :password}
      let(:name) {FactoryGirl.generate :name}
      let(:birthdate) {FactoryGirl.generate :birthdate}
      let(:gender) {FactoryGirl.generate :gender}

      context "With an invalid instance" do
        let(:instance_token) {"INVALID"}

        it {expect(response.status).to eq 200}
        it {expect(json['error_code']).to eq 1001}
        it {expect(json['error_message']).to match /Invalid instance token/}
      end

      context "With a valid instance" do
        let(:instance) {FactoryGirl.create :instance}
        let(:instance_token) {instance.uuid}

        it {expect(response.status).to eq 201}
        it {expect(json).to_not be_nil}
        it {expect(json['error_code']).to be_nil}
        it {expect(json['error_message']).to be_nil}
        it "The user should be tied to the instance" do
          instance = Instance.find_by uuid:instance_token
          user = User.find_by email:email
          expect(instance.user).to eq user
        end

        context "When the instance doesn't exist" do
          let(:instance_token) {"INVALID"}

          it {expect(response.status).to eq 200}
          it {expect(json).to_not be_nil}
          it {expect(json['error_code']).to eq 1001}
          it {expect(json['error_message']).to match /Invalid instance token/}
        end

        context "When the instance exists" do
          context "When a user with the email adready exists" do
            let(:user) {FactoryGirl.create :user}
            let(:email) {user.email}

            it {expect(response.status).to eq 200}
            it {expect(json).to_not be_nil}
            it {expect(json['error_code']).to eq 1002}
            it {expect(json['error_message']).to match /already registered/}
          end

          context "When a user with the username already exists" do
            let(:user) {FactoryGirl.create :user}
            let(:username) {user.username}

            it {expect(response.status).to eq 200}
            it {expect(json).to_not be_nil}
            it {expect(json['error_code']).to eq 1009}
            it {expect(json['error_message']).to match /is already taken/}
          end

          context "When a user with the email doesn't already exist" do
            it {expect(response.status).to eq 201}
            it {expect(json).to_not be_nil}
            it {expect(json['error_code']).to be_nil}
            it {expect(json['error_message']).to be_nil}
            it {expect(User.find_by(email:email)).to_not be_nil}
            it {expect(User.find_by(username:username.downcase)).to_not be_nil}
            it {expect(User.find_by(username:username.downcase)).to eq User.find_by(email:email)}
            it {expect(Instance.find_by(uuid:instance_token).user.id).to eq User.find_by(email:email).id}
            it {expect(json['auth_token']).to eq Instance.find_by(uuid:instance_token).user.auth_token}
            it {expect(json['user_id']).to eq User.find_by(email: email).id}

            it {expect(User.find_by(email:email).name).to eq name}
            it "The user should be tied to the instance" do
              instance = Instance.find_by uuid:instance_token
              user = User.find_by email:email
              expect(instance.user).to eq user
            end

            context "When the user is under 14 years old" do
              let(:birthdate) {Date.current - 12.years}

              it {expect(response.status).to eq 200}
              it {expect(json).not_to be_nil}
              it {expect(json['error_code']).to eq 1010}
              it {expect(json['error_message']).to match /Birthdate must be over 13 years ago/}
            end
          end
        end
      end
    end
  end
end
