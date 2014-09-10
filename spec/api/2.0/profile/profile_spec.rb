require 'rails_helper'

describe :profile do
    let(:params) {{}}
    before { post "v/2.0/profile", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

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

        it {expect(JSON.parse(response.body)['profile'].count).to eq 7}
        context "With no questions answered" do
          it {expect(JSON.parse(response.body)['profile']['number_of_answered_questions']).to eq 0}
        end
        context "With no questions asked" do
          it {expect(JSON.parse(response.body)['profile']['number_of_asked_questions']).to eq 0}
        end
        context "With no comments left" do
          it {expect(JSON.parse(response.body)['profile']['number_of_comments_left']).to eq 0}
        end

      end
    end

end