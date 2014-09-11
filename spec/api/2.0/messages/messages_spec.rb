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

        context "With one of each type of message" do

          let(:count) { 2 }
          let(:other_user) {FactoryGirl.create :user}

          let(:auto_generate_messages_for_question_updated) {FactoryGirl.create_list(:text_response, count,
                                                               user: user,
                                                               comment: "first!") }
          let(:auto_generate_message_for_user_followed) {other_user.follow! user}

          let(:setup_messages) {
            auto_generate_messages_for_question_updated
            auto_generate_message_for_user_followed
          }

          describe "Message Output" do
            it {expect(Response.count).to eq 2}

            it {expect(JSON.parse(response.body).count).to eq 3}

            describe "First QuestionUpdated" do
              it {expect(JSON.parse(response.body)[0]['message']['type']).to eq "QuestionUpdated"}
              it {expect(JSON.parse(response.body)[0]['message'].count).to eq 8}

              it {expect(JSON.parse(response.body)[0]['message']['comment_count']).to eq 1}
              it {expect(JSON.parse(response.body)[0]['message']['share_count']).to eq 0}

            end

            describe "Second QuestionUpdated" do
              it {expect(JSON.parse(response.body)[1]['message']['type']).to eq "QuestionUpdated"}
              it {expect(JSON.parse(response.body)[1]['message'].count).to eq 8}

              it {expect(JSON.parse(response.body)[1]['message']['comment_count']).to eq 1}
              it {expect(JSON.parse(response.body)[1]['message']['share_count']).to eq 0}

            end

            describe "UserFollowed" do
              it {expect(JSON.parse(response.body)[2]['message']['type']).to eq "UserFollowed"}
              it {expect(JSON.parse(response.body)[2]['message'].count).to eq 4}


            end


          end
        end
      end
    end
  end
end