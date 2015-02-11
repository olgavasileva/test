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
        let(:params) {{ auth_token: auth_token, provider: provider, version: version, raw_data: raw_data }}
        let(:provider) {"quantcast"}
        let(:version) {"1.0"}

        context "With one set of raw data" do
          let(:raw_data) {"qcseg=D;qcseg=T;qcseg=50082;qcseg=50079;qcseg=50076;qcseg=50075;qcseg=50074;qcseg=50073;qcseg=50062;qcseg=50060;qcseg=50059;qcseg=50057;qcseg=50054;"}

          it {expect(response.status).to eq 201}
          it {expect(user.reload.demographic).to be_present}
          it {expect(user.reload.demographic.data_provider).to eq provider}
          it {expect(user.reload.demographic.data_version).to eq version}
          it {expect(user.reload.demographic.raw_data).to eq raw_data}
          it {expect(user.reload.demographic.gender).to eq 'male'}
          it {expect(user.reload.demographic.household_income).to eq '100k+'}
          it {expect(user.reload.demographic.children).to eq "true"}
          it {expect(user.reload.demographic.ethnicity).to eq "caucasian"}
          it {expect(user.reload.demographic.education_level).to eq "college"}
          it {expect(user.reload.demographic.political_affiliation).to be_nil}
          it {expect(user.reload.demographic.political_engagement).to be_nil}
        end

        context "With a different set of raw data" do
          let(:raw_data) {"qcseg=D;qcseg=T;qcseg=50083;qcseg=50068;qcseg=50067;qcseg=50066;qcseg=50065;qcseg=50060;qcseg=50059;qcseg=50057;qcseg=50081;qcseg=50070;"}

          it {expect(response.status).to eq 201}
          it {expect(user.reload.demographic).to be_present}
          it {expect(user.reload.demographic.data_provider).to eq provider}
          it {expect(user.reload.demographic.data_version).to eq version}
          it {expect(user.reload.demographic.raw_data).to eq raw_data}
          it {expect(user.reload.demographic.gender).to eq 'female'}
          it {expect(user.reload.demographic.household_income).to eq '0-100k'}
          it {expect(user.reload.demographic.children).to eq "false"}
          it {expect(user.reload.demographic.ethnicity).to eq "hispanic"}
          it {expect(user.reload.demographic.education_level).to eq "no_college"}
          it {expect(user.reload.demographic.political_affiliation).to be_nil}
          it {expect(user.reload.demographic.political_engagement).to be_nil}
        end
      end
    end
  end


end

