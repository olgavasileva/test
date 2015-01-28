require 'rails_helper'

describe :profile do
    let(:params) {{}}

    let(:before_api_call) {}
    before { before_api_call }

    before { post "v/2.0/profile", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

    let(:params) {{auth_token:auth_token}}
    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 402}
      it {expect(JSON.parse(response.body)['error_message']).to match /Invalid auth token/}
    end

    context "With a logged in user" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :logged_in}
      let(:user) {instance.user}

      context "With anothe user" do
        let(:other_user) {FactoryGirl.create :user}

        let(:before_api_call) {
          other_user.follow! user
        }

        it {expect(JSON.parse(response.body)['profile'].count).to eq 8}
        context "With no questions answered" do
          it {expect(JSON.parse(response.body)['profile']['number_of_answered_questions']).to eq 0}
        end
        context "With no questions asked" do
          it {expect(JSON.parse(response.body)['profile']['number_of_asked_questions']).to eq 0}
        end
        context "With no comments left" do
          it {expect(JSON.parse(response.body)['profile']['number_of_comments_left']).to eq 0}
        end
        context "With no comments left" do
          it {expect(JSON.parse(response.body)['profile']['number_of_comments_left']).to eq 0}
        end
        context "With one follower" do
          it {expect(JSON.parse(response.body)['profile']['number_of_followers']).to eq 1}
        end

        context "with user_id param" do
          let(:other_user) { FactoryGirl.create(:user) }
          let(:params) { {
            auth_token: auth_token,
            user_id: other_user.id
          } }

          it "returns data for that user" do
            response_body = JSON.parse(response.body)
            expect(response_body['profile']['user_id']).to eq other_user.id
          end
        end

      end
    end

end
