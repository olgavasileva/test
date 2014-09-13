require 'rails_helper'

describe :read do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/messages/read", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token, id:message_id}}
    let(:message_id) {0}

    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 402}
      it {expect(JSON.parse(response.body)['error_message']).to match /Invalid auth token/}
    end

    context "With an unauthorized instance" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :unauthorized}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 403}
      it {expect(JSON.parse(response.body)['error_message']).to match /Login required/}
    end

    context "With an authorized instance" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :authorized, user:user}

      context "When no user is associated with the instance" do
        let(:user) {}

        it {expect(response.status).to eq 200}
        it {expect(JSON.parse(response.body)['error_code']).to eq 403}
        it {expect(JSON.parse(response.body)['error_message']).to match /Login required/}
      end

      context "When a user is associated with the instance" do
        let(:user) {FactoryGirl.create :user}

        context "and the target message doesn't exist" do
          let(:message_id) {0}

          it {expect(response.status).to eq 200}
          it {expect(JSON.parse(response.body)).to_not be_nil}
          it {expect(JSON.parse(response.body)['error_code']).to eq 2000}
          it {expect(JSON.parse(response.body)['error_message']).to match /The message doesn't exist/}
        end

        context "and the target message doesn't belong to current user" do
          let(:other_user) {FactoryGirl.create :user}
          let(:message) {FactoryGirl.create :question_liked_message, user:other_user}
          let(:message_id) {message.id}

          it {expect(response.status).to eq 200}
          it {expect(JSON.parse(response.body)).to_not be_nil}
          it {expect(JSON.parse(response.body)['error_code']).to eq 2001}
          it {expect(JSON.parse(response.body)['error_message']).to match /The message doesn't belong to current_user/}
        end

        context "and the target message has already been read" do
          let(:message) {FactoryGirl.create :question_liked_message, user:user, read_at:Time.zone.now()}
          let(:before_api_call) {
            message.read_at = Time.zone.now()
            message.save
          }
          let(:message_id) {message.id}

          it {expect(response.status).to eq 200}
          it {expect(JSON.parse(response.body)).to_not be_nil}
          it {expect(JSON.parse(response.body)['error_code']).to eq 2002}
          it {expect(JSON.parse(response.body)['error_message']).to match /The message has already been read/}
        end

        context "and the target message is all right" do
          let(:message) {FactoryGirl.create :question_liked_message, user:user}
          let(:message_id) {message.id}

          it {expect(response.status).to eq 200}
          it {expect(response.body).to eq "[]"}

        end


      end
    end
  end
end