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

      context "When no user is associated with the instnace" do
        let(:user) {}

        it {expect(response.status).to eq 200}
        it {expect(JSON.parse(response.body)['error_code']).to eq 403}
        it {expect(JSON.parse(response.body)['error_message']).to match /Login required/}
      end

      context "When a user is associated with the instnace" do
        let(:user) {FactoryGirl.create :user}

        context "With no questions" do
          it {expect(JSON.parse(response.body)).to eq []}
        end

        context "With one of each type of question" do

          let(:direct_question_message) {FactoryGirl.create :direct_question_message, user:user}
          let(:question_liked_message) {FactoryGirl.create :question_liked_message, user:user}
          let(:comment_liked_message) {FactoryGirl.create :comment_liked_message, user:user}


          let(:setup_messages) {
            direct_question_message
            question_liked_message
            comment_liked_message
          }

          describe "Message Output" do
            it {expect(JSON.parse(response.body).count).to eq 3}

            describe "DirectQuestionMessage" do
              it {expect(JSON.parse(response.body)[0]['message']['type']).to eq "DirectQuestionMessage"}
              it {expect(JSON.parse(response.body)[0]['message']['content']).to eq "This is a direct question message."}
            end

            describe "QuestionLikedMessage" do
              it {expect(JSON.parse(response.body)[1]['message']['type']).to eq "QuestionLikedMessage"}
              it {expect(JSON.parse(response.body)[1]['message']['content']).to eq "This is a question liked message."}
            end
            describe "CommentLikedMessage" do
              it {expect(JSON.parse(response.body)[2]['message']['type']).to eq "CommentLikedMessage"}
              it {expect(JSON.parse(response.body)[2]['message']['content']).to eq "This is a comment liked message."}
            end
          end
        end
      end
    end
  end
end