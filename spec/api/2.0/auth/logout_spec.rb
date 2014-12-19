require 'rails_helper'

describe :logout do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/logout", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {JSON.parse(response.body)['error_code'].should eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{instance_token:instance_token}}

    context "With an invalid instance" do
      let(:instance_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {JSON.parse(response.body).should_not be_nil}
      it {expect(JSON.parse(response.body)['error_code']).to eq 1001}
      it {expect(JSON.parse(response.body)['error_message']).to match /Invalid instance token/}
    end

    context "With a valid instance" do
      let(:instance_token) {instance.uuid}

      context "When the instance is authorized and logged in" do
        let(:instance) {FactoryGirl.create :instance, :logged_in}

        it {expect(response.status).to eq 201}
        it {JSON.parse(response.body).should_not be_nil}
        it {expect(JSON.parse(response.body)['error_code']).to be_nil}
        it {expect(JSON.parse(response.body)['error_message']).to be_nil}
        it {expect(instance.user.reload.auth_token).to be_nil}
        it {expect(instance.reload.user).to be_nil}
      end
    end
  end
end