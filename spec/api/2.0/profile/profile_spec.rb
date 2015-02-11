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
      it {expect(json['error_code']).to eq 402}
      it {expect(json['error_message']).to match /Invalid auth token/}
    end

    context "With a logged in user" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :logged_in}

      context "With another user" do
        let(:other_user) {FactoryGirl.create :user}
        let(:user) {instance.user}

        let(:before_api_call) {
          other_user.follow! user
        }

        it {expect(json["profile"].keys).to match_array %w[username email user_id member_since number_of_asked_questions number_of_answered_questions number_of_comments_left number_of_followers]}
        it {expect(json["profile"]["pro_dashboard_url"]).to be_nil}

        context "When the user is a pro" do
          let(:instance) {FactoryGirl.create :instance, :logged_in, user: user}
          let(:user) {FactoryGirl.create :user, :pro}

          it {expect(json["profile"]["pro_dashboard_url"]).to eq "http://example.com/users/#{user.id}/dashboard"}
        end

        context "With no questions answered" do
          it {expect(json['profile']['number_of_answered_questions']).to eq 0}
        end
        context "With no questions asked" do
          it {expect(json['profile']['number_of_asked_questions']).to eq 0}
        end
        context "With no comments left" do
          it {expect(json['profile']['number_of_comments_left']).to eq 0}
        end
        context "With no comments left" do
          it {expect(json['profile']['number_of_comments_left']).to eq 0}
        end
        context "With one follower" do
          it {expect(json['profile']['number_of_followers']).to eq 1}
        end

        context "with user_id param" do
          let(:other_user) { FactoryGirl.create(:user) }
          let(:params) { {
            auth_token: auth_token,
            user_id: other_user.id
          } }

          it "returns data for that user" do
            response_body = json
            expect(response_body['profile']['user_id']).to eq other_user.id
          end
        end

      end
    end

end
