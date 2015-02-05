require 'rails_helper'

describe :demographics do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/demographics", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

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
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :logged_in}
      let(:user) {instance.user}

      it {expect(response.status).to eq 201}
      it {expect(user.reload.demographic).to be_present}

      context "Whith all values set" do
        let(:params) {{ auth_token: auth_token, gender: gender, age_range: age_range, household_income: household_income, children: children, ethnicity: ethnicity, education_level: education_level, political_affiliation: political_affiliation, political_engagement: political_engagement }}
        let(:gender) {"male"}
        let(:age_range) {"18-24"}
        let(:household_income) {"0-50k"}
        let(:children) {"true"}
        let(:ethnicity) {"other"}
        let(:education_level) {"college"}
        let(:political_affiliation) {"independent"}
        let(:political_engagement) {"inactive"}

        it {expect(response.status).to eq 201}
        it {expect(user.reload.demographic).to be_present}
        it {expect(user.reload.demographic.gender).to eq gender}
        it {expect(user.reload.demographic.age_range).to eq age_range}
        it {expect(user.reload.demographic.household_income).to eq household_income}
        it {expect(user.reload.demographic.children).to eq children}
        it {expect(user.reload.demographic.ethnicity).to eq ethnicity}
        it {expect(user.reload.demographic.education_level).to eq education_level}
        it {expect(user.reload.demographic.political_affiliation).to eq political_affiliation}
        it {expect(user.reload.demographic.political_engagement).to eq political_engagement}
      end
    end
  end


end

