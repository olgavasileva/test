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

  context "With valid required params" do
    let(:params) {{ auth_token: auth_token, provider: provider, version: version, raw_data: raw_data }}
    let(:provider) {"quantcast"}
    let(:version) {"1.0"}
    let(:raw_data) {"NULL"}

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

      context "With a set of specific valid raw data" do
        let(:raw_data) {'[{"id":"D"},{"id":"T"},{"id":"50082"},{"id":"50079"},{"id":"50076"},{"id":"50075"},{"id":"50074"},{"id":"50073"},{"id":"50062"},{"id":"50060"},{"id":"50059"},{"id":"50057"},{"id":"50054"}]'}

        it {expect(response.status).to eq 201}
        it {expect(user.reload.demographics.quantcast.first).to be_present}
        it {expect(user.reload.demographics.quantcast.first.data_provider_name).to eq provider}
        it {expect(user.reload.demographics.quantcast.first.data_version).to eq version}
        it {expect(user.reload.demographics.quantcast.first.raw_data).to eq raw_data}
        it {expect(user.reload.demographics.quantcast.first.gender).to eq 'male'}
        it {expect(user.reload.demographics.quantcast.first.household_income).to eq '100k+'}
        it {expect(user.reload.demographics.quantcast.first.children).to eq "true"}
        it {expect(user.reload.demographics.quantcast.first.ethnicity).to eq "caucasian"}
        it {expect(user.reload.demographics.quantcast.first.education_level).to eq "college"}
        it {expect(user.reload.demographics.quantcast.first.political_affiliation).to be_nil}
        it {expect(user.reload.demographics.quantcast.first.political_engagement).to be_nil}
      end

      context "With a different set of valid raw data" do
        let(:raw_data) {'[{"id":"D"},{"id":"T"},{"id":"50083"},{"id":"50068"},{"id":"50067"},{"id":"50066"},{"id":"50065"},{"id":"50060"},{"id":"50059"},{"id":"50057"},{"id":"50081"},{"id":"50070"}]'}

        it {expect(response.status).to eq 201}
        it {expect(user.reload.demographics.quantcast.first).to be_present}
        it {expect(user.reload.demographics.quantcast.first.data_provider_name).to eq provider}
        it {expect(user.reload.demographics.quantcast.first.data_version).to eq version}
        it {expect(user.reload.demographics.quantcast.first.raw_data).to eq raw_data}
        it {expect(user.reload.demographics.quantcast.first.gender).to eq 'female'}
        it {expect(user.reload.demographics.quantcast.first.household_income).to eq '0-100k'}
        it {expect(user.reload.demographics.quantcast.first.children).to eq "false"}
        it {expect(user.reload.demographics.quantcast.first.ethnicity).to eq "hispanic"}
        it {expect(user.reload.demographics.quantcast.first.education_level).to eq "no_college"}
        it {expect(user.reload.demographics.quantcast.first.political_affiliation).to be_nil}
        it {expect(user.reload.demographics.quantcast.first.political_engagement).to be_nil}
      end
    end
  end
end

