require 'rails_helper'

describe :messages do
  let(:params) {{}}
  let(:setup_messages) {}
  before { setup_messages }
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/messages", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(json).to_not be_nil}
    it {expect(json['error_code']).to eq 400}
    it {expect(json['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token}}

    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(json['error_code']).to eq 402}
      it {expect(json['error_message']).to match /Invalid auth token/}
    end

    context "With a logged in user" do
      let(:auth_token) {user.auth_token}
      let(:user) {FactoryGirl.create :user, :authorized}

      context "With no messages" do
        it {expect(json['number_of_unread_messages']).to eq 0}
      end

      context "With one of each type of message" do

        let(:other_user) {FactoryGirl.create :user}

        let(:targeted_question) { FactoryGirl.create :question, kind: 'targeted'}
        let(:m1) { FactoryGirl.create :question_updated, question: targeted_question, user: user }
        let(:m2) { FactoryGirl.create :user_followed, user: user }
        let(:m3) { FactoryGirl.create :custom, user: user }
        let(:messages) { [ m1, m2, m3 ] }

        let(:setup_messages) { messages }

        describe "Message Output" do
          it {expect(json['number_of_unread_messages']).to eq 3}

          it "should return messages in order from newest to oldest" do
            expect(json['messages'].map{|m| m['message']['id']}).to eq messages.map{|m| m.id}.reverse
          end

          describe "QuestionUpdated" do
            it {expect(json['messages'][2]['message']['type']).to eq "QuestionUpdated"}
            it {expect(json['messages'][2]['message'].keys).to match_array %w(id type body question_id response_count comment_count share_count completed_at created_at read_at)}

            it {expect(json['messages'][2]['message']['comment_count']).to eq 0}
            it {expect(json['messages'][2]['message']['share_count']).to eq 0}

          end


          describe "UserFollowed" do
            it {expect(json['messages'][1]['message']['type']).to eq "UserFollowed"}
            it {expect(json['messages'][1]['message'].keys).to match_array %w(id type body follower_id created_at read_at)}
          end

          describe "Custom" do
            it {expect(json['messages'][0]['message']['type']).to eq "Custom"}
            it {expect(json['messages'][0]['message'].keys).to match_array %w(id type body created_at read_at)}
          end

        end
      end
    end
  end
end
