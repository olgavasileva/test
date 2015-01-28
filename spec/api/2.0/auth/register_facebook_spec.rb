require 'rails_helper'

describe :register_facebook do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/register/facebook", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(json).to_not be_nil}
    it {expect(json['error_code']).to eq 400}
    it {expect(json['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{instance_token:instance_token, facebook_token:facebook_token, username:username, birthdate:birthdate}}
    let(:birthdate) {Date.current - 20.years}

    context "With valid facebook_token and username params" do
      let(:facebook_token) {"some_token"}
      let(:username) {FactoryGirl.generate :username}

      context "With an invalid instance" do
        let(:instance_token) {"INVALID"}

        it {response.status.should eq 200}
        it {json['error_code'].should eq 1001}
        it {expect(json['error_message']).to match /Invalid instance token/}
      end

      context "With a valid instance" do
        let(:instance) {FactoryGirl.create :instance}
        let(:instance_token) {instance.uuid}

        context "With an invalid facebook token" do
          let(:before_api_call) {Koala::Facebook::API.should_receive(:new).and_raise Exception.new}

          it {response.status.should eq 200}
          it {json['error_code'].should eq 1002}
          it {json['error_message'].should match /Could not access facebook profile/}
        end

        context "With a valid facebook token" do
          let(:graph){double :graph}
          let(:fid) {"123"}
          let(:before_api_call) do
            Koala::Facebook::API.stub(:new).with(facebook_token).and_return(graph)
            graph.stub(:get_object).with("me").and_return(profile)
          end

          context "With a profile with no email" do
            let(:profile){{"id" => fid}}

            it {response.status.should eq 200}
            it {json['error_code'].should eq 1003}
            it {json['error_message'].should match /Facebook profile has no email/}
          end

          context "With a profile with an email" do
            let(:profile){{"id" => fid, "email" => email}}
            let(:email){FactoryGirl.generate :email_address}

            context "With a profile with no name" do
              it {response.status.should eq 200}
              it {json['error_code'].should eq 1004}
              it {json['error_message'].should match /Facebook profile has no name/}
            end

            context "With a profile with a name" do
              let(:profile){{"id" => fid, "email" => email, "name" => name}}
              let(:name) {FactoryGirl.generate :name}

              it {response.status.should eq 201}
              it {expect(json['error_code']).to be_nil}
              it {json['error_message'].should be_nil}

              context "When another user has a matching username" do
                let(:other_user) {FactoryGirl.create :user}
                let(:username) {other_user.username}

                it {response.status.should eq 200}
                it {json['error_code'].should eq 1009}
                it {json['error_message'].should match /Username is already taken/}
              end

              context "When there is an existing authentication with this fid" do
                let(:fid) {authentication.uid}
                let(:authentication) {FactoryGirl.create :authentication, :facebook}

                it {response.status.should eq 201}
                it {json['error_code'].should be_nil}
                it {json['error_message'].should be_nil}
                it {json['auth_token'].should eq instance.reload.auth_token}
                it {json['user_id'].should eq instance.reload.user.id}
                it {instance.reload.user.should eq authentication.user}
                it {instance.reload.user.authentications.find_by(uid:fid).id.should eq authentication.id}
              end

              context "Whent there is not an existing authentication with this fid" do
                context "When a user with the email adready exists" do
                  let(:user) {FactoryGirl.create :user}
                  let(:email) {user.email}

                  it {response.status.should eq 201}
                  it {expect(json['error_code']).to be_nil}
                  it {expect(json['error_message']).to be_nil}
                  it {user.reload.instances.should include instance}
                  it {instance.reload.user.authentications.find_by(uid:fid).should be_present}
                end

                context "When a user with the email doesn't already exist" do
                  it {response.status.should eq 201}
                  it {json['error_code'].should be_nil}
                  it {json['error_message'].should be_nil}
                  it {User.find_by(email:email).should_not be_nil}
                  it {Instance.find_by(uuid:instance_token).user.id.should eq User.find_by(email:email).id}
                  it {expect(json['auth_token']).to eq Instance.find_by(uuid:instance_token).auth_token}
                end
              end
            end
          end
        end
      end
    end
  end
end
