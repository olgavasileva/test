require 'rails_helper'

describe :login do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/login", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  shared_examples_for :returns_error do |code, msg|
    it 'returns the right error_code' do
      expect(json['error_code']).to eq(code)
    end

    it 'returns the right error_message' do
      expect(json['error_message']).to match(msg)
    end
  end

  context "Without the required params" do
    include_examples :returns_error, 400, /is missing/
  end

  context 'when associating the :provider_id' do
    let(:auth) { FactoryGirl.create(:authentication, :facebook, user: nil) }
    let(:auth_id) { auth.id }
    let(:instance) { FactoryGirl.create(:instance, :logged_in) }
    let(:user) { instance.user }

    let(:params) do
      {
        instance_token: instance.uuid,
        email: user.email,
        password: user.password,
        provider_id: auth_id
      }
    end

    context 'when the :provider_id is valid' do
      it 'updates the Authentication record' do
        expect(auth.reload.user).to eq(user)
      end

      it 'is successful' do
        expect(response.status).to eq(201)
      end
    end

    context 'when the :provider_id is invalid' do
      let(:auth_id) { 9999999 }
      include_examples :returns_error, 1012, /Provider could not be found/
    end
  end

  describe "Logging in with an email address" do
    context "With all required params" do
      let(:params) {{instance_token:instance_token, email:email, password:password}}

      context "With a valid email and password" do
        let(:email) {FactoryGirl.generate :email_address}
        let(:password) {FactoryGirl.generate :password}

        context "With an invalid instance" do
          let(:instance_token) {"INVALID"}
          include_examples :returns_error, 1001, /Invalid instance token/
        end

        context "With a valid instance" do
          let(:instance) {FactoryGirl.create :instance}
          let(:instance_token) {instance.uuid}

          context "With both email and username" do
            let(:params) {{email:email, username:username, password:password, instance_token:instance_token}}
            let(:username) {FactoryGirl.generate :username}

            include_examples :returns_error, 400, /email, username are mutually exclusive/
          end

          context "With neither email nor password " do
            let(:params) {{password:password, instance_token:instance_token}}

            include_examples :returns_error, 1006, /Neither email nor username supplied/
          end

          context "When a user with the email doesn't already exist" do
            let (:email) {FactoryGirl.generate :email_address}

            include_examples :returns_error, 1008, /Login Unsuccessful/
          end

          context "When a user with the email adready exists" do
            let(:user) {FactoryGirl.create :user, password:password}
            let(:email) {user.email}

            context "When the password is incorrect" do
              let(:user) {FactoryGirl.create :user, password:"INCORRECT"}

              include_examples :returns_error, 1008, /Login Unsuccessful/
            end

            context "When the instance already has an existing auth_token" do
              let(:instance) { FactoryGirl.create(:instance, :logged_in) }

              it 'returns the correct response' do
                instance.reload

                expect(response.status).to eq(201)
                expect(json).to eq({
                  'auth_token' => instance.auth_token,
                  'email' => user.email,
                  'username' => user.username,
                  'user_id' => user.id
                })
              end

              it "change the auth token" do
                expect(json['auth_token']).to_not eq instance.auth_token
              end

              it "associates the instance with the user" do
                instance = Instance.find_by uuid:instance_token
                expect(instance.user).to eq user
              end
            end

            context "When the user is logged in on another instance" do
              let(:other_instance) do
                FactoryGirl.create(:instance, :logged_in, user: user)
              end

              let(:user) { FactoryGirl.create(:user, password: password) }
              let(:before_api_call)  { other_instance }

              it 'returns the correct response' do
                instance.reload

                expect(response.status).to eq(201)
                expect(json).to eq({
                  'auth_token' => instance.auth_token,
                  'email' => user.email,
                  'username' => user.username,
                  'user_id' => user.id
                })
              end

              it "should not be the same auth_token as the other instance" do
                expect(instance.reload.auth_token).to_not eq other_instance.reload.auth_token
              end

              it "associates the user with the instance" do
                instance.reload
                expect(instance.user).to eq(user)
              end
            end

            context "When the instance doesn't have an auth_token" do
              let(:instance) { FactoryGirl.create(:instance, :logged_out, user: user) }
              let(:user) { FactoryGirl.create(:user, password: password) }

              it 'returns the correct response' do
                instance.reload

                expect(response.status).to eq(201)
                expect(json).to eq({
                  'auth_token' => instance.auth_token,
                  'email' => user.email,
                  'username' => user.username,
                  'user_id' => user.id
                })
              end

              it "associates the user with the instance" do
                instance.reload
                expect(instance.user).to eq(user)
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

        context "With an invalid instance" do
          let(:instance_token) {"INVALID"}

          include_examples :returns_error, 1001, /Invalid instance token/
        end

        context "With a valid instance" do
          let(:instance) {FactoryGirl.create :instance}
          let(:instance_token) {instance.uuid}

          context "When a user with the username doesn't already exist" do
            let (:username) {FactoryGirl.generate :username}

            include_examples :returns_error, 1008, /Login Unsuccessful/
          end

          context "When a user with the username adready exists" do
            let(:user) {FactoryGirl.create :user, password:password}
            let(:username) {user.username}

            context "When the password is incorrect" do
              let(:user) {FactoryGirl.create :user, password:"INCORRECT"}

              include_examples :returns_error, 1008, /Login Unsuccessful/
            end

            context "When the instance already has an existing auth_token" do
              let(:instance) {FactoryGirl.create :instance, :logged_in}

              it 'returns the correct response' do
                instance.reload

                expect(response.status).to eq(201)
                expect(json).to eq({
                  'auth_token' => instance.auth_token,
                  'email' => user.email,
                  'username' => user.username,
                  'user_id' => user.id
                })
              end

              it "should change the auth token" do
                expect(json['auth_token']).to_not eq instance.auth_token
              end

              it "associates the user with the instance" do
                instance.reload
                expect(instance.user).to eq(user)
              end
            end

            context "When the user is logged in on another instance" do
              let(:before_api_call) {other_instance}
              let(:other_instance) {FactoryGirl.create :instance, :logged_in, user:user}
              let(:user) {FactoryGirl.create :user, password:password}

              it 'returns the correct response' do
                instance.reload

                expect(response.status).to eq(201)
                expect(json).to eq({
                  'auth_token' => instance.auth_token,
                  'email' => user.email,
                  'username' => user.username,
                  'user_id' => user.id
                })
              end

              it "should not be the same auth_token as the other instance" do
                expect(instance.reload.auth_token).to_not eq other_instance.reload.auth_token
              end

              it "associates the user with the instance" do
                instance.reload
                expect(instance.user).to eq(user)
              end
            end

            context "When the instance doesn't have an auth_token" do
              let(:instance) {FactoryGirl.create :instance, :logged_out, user:user}
              let(:user) {FactoryGirl.create :user, password:password}

              it 'returns the correct response' do
                instance.reload

                expect(response.status).to eq(201)
                expect(json).to eq({
                  'auth_token' => instance.auth_token,
                  'email' => user.email,
                  'username' => user.username,
                  'user_id' => user.id
                })
              end

              it "associates the user with the instance" do
                instance.reload
                expect(instance.user).to eq(user)
              end
            end
          end
        end
      end
    end
  end
end
