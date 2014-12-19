require 'rails_helper'

describe :read do
  let(:params) {{}}
  let(:setup_messages) {}
  before { setup_messages }
  before { post "v/2.0/messages/read_all", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token}}

    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 402}
      it {expect(JSON.parse(response.body)['error_message']).to match /Invalid auth token/}
    end

    context "With an authorized user" do
      let(:user) {FactoryGirl.create :user, :authorized}
      let(:auth_token) {user.auth_token}

      context "When a user has all types of messages" do

        let(:count) { 2 }
        let(:other_user) {FactoryGirl.create :user}

        let(:text_question_1) {FactoryGirl.create(:text_question, kind: 'targeted', user: user)}
        let(:auto_generate_message_for_question_updated) {
          FactoryGirl.create(:text_response, question: text_question_1, user: other_user)
        }
        let(:auto_generate_message_for_user_followed) {other_user.follow! user}
        let(:generate_message_for_custom) {FactoryGirl.create :custom, user:user}
        let(:setup_messages) {
          auto_generate_message_for_question_updated
          auto_generate_message_for_user_followed
          generate_message_for_custom
        }


        context "and all the messages are read" do
          it {expect(response.status).to eq 200}
          it {expect(response.body).to eq "{}"}
        end

      end
    end
  end
end