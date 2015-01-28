require 'rails_helper'

describe :promote do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/promote", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(json).to_not be_nil}
    it {expect(json['error_code']).to eq 400}
    it {expect(json['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token, email:email, username:username, password:password, name:name, birthdate:birthdate, gender:gender}}

    context "With valid email, username, password, and name params" do
      let(:email) {FactoryGirl.generate :email_address}
      let(:username) {FactoryGirl.generate :username}
      let(:password) {FactoryGirl.generate :password}
      let(:name) {FactoryGirl.generate :name}
      let(:birthdate) {FactoryGirl.generate :birthdate}
      let(:gender) {FactoryGirl.generate :gender}

      context "With an invalid auth token" do
        let(:auth_token) {"INVALID"}

        it {expect(response.status).to eq 200}
        it {expect(json['error_code']).to eq 402}
        it {expect(json['error_message']).to match /Invalid auth token/}
      end

      context "With an auth token from a User (not an anonymous user)" do
        let(:instance) {FactoryGirl.create :instance, :logged_in}
        let(:auth_token) {instance.auth_token}

        it {expect(response.status).to eq 200}
        it {expect(json['error_code']).to eq 1012}
        it {expect(json['error_message']).to match /User must be anonymous/}
      end

      context "With an auth token from an anonymous user" do
        let(:anonymous) {FactoryGirl.create :anonymous}
        let(:instance) {FactoryGirl.create :instance, :logged_in, user: anonymous}
        let(:auth_token) {instance.auth_token}

        it {expect(response.status).to eq 201}
        it {expect(json).to_not be_nil}
        it {expect(json['error_code']).to be_nil}
        it {expect(json['error_message']).to be_nil}

        it "The old auth_token should not work" do
          expect(Instance.find_by auth_token:auth_token).to be_nil
          expect(auth_token).not_to eq json["auth_token"]
        end

        it "The resulting user should have the same id as the Anonymous user" do
          user = Instance.find_by(auth_token:json["auth_token"]).user
          expect(user.id).to eq anonymous.id
        end

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
          it {expect(json['user_id']).to eq User.find_by(email: email).id}
          it {expect(User.find_by(email:email).name).to eq name}

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