require 'rails_helper'

describe :anonymous do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/users/anonymous", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(json).to_not be_nil}
    it {expect(json['error_code']).to eq 400}
    it {expect(json['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{instance_token:instance_token}}

    context "With an invalid instance" do
      let(:instance_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(json['error_code']).to eq 1001}
      it {expect(json['error_message']).to match /Invalid instance token/}
    end

    context "With a valid instance" do
      let(:instance) {FactoryGirl.create :instance}
      let(:instance_token) {instance.uuid}

      it {expect(response.status).to eq 201}
      it {expect(json).to_not be_nil}
      it {expect(json['error_code']).to be_nil}
      it {expect(json['error_message']).to be_nil}
      it {expect(json.keys).to match_array %w(auth_token username email user_id)}

      it "The user should be tied to the instance" do
        instance = Instance.find_by uuid:instance_token
        respondent = Respondent.find_by auth_token:json['auth_token']
        expect(instance.user).to eq respondent
      end
    end
  end
end
