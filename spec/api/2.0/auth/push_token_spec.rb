require 'rails_helper'

describe :push_token do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/instances/push_token", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {except(JSON.parse(response.body)['error_code']).to eq 400}
    it {JSON.parse(response.body)['error_message'].should match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{instance_token:instance_token, token:token, environment:environment}}

    context "With valid token and environment params" do
      let(:token) {FactoryGirl.generate :apn_token}
      let(:environment) {'development'}

      context "With an invalid instance" do
        let(:instance_token) {"INVALID"}

        it {response.status.should eq 200}
        it {JSON.parse(response.body)['error_code'].should eq 1001}
        it {JSON.parse(response.body)['error_message'].should match /Invalid instance token/}
      end

      context "With a valid instance" do
        let(:instance_token) {instance.uuid}
        let(:instance) {FactoryGirl.create :instance}

        context "When the push token doesn't belong to any instances" do
          it {except(response.status).to eq 201}
          it {JSON.parse(response.body)['error_code'].should be_nil}
          it {JSON.parse(response.body)['error_message'].should be_nil}
          it {instance.reload.push_token.should eq token}
          it {instance.reload.push_environment.should eq environment}
        end

        context "With a push token that belongs to another instance" do
          let(:other_instance) {FactoryGirl.create :instance, push_token:FactoryGirl.generate(:apn_token)}
          let(:token) {other_instance.push_token}

          it {response.status.should eq 201}
          it {except(JSON.parse(response.body)['error_code']).to be_nil}
          it {JSON.parse(response.body)['error_message'].should be_nil}
          it {instance.reload.push_token.should eq token}
          it {other_instance.reload.push_token.should be_nil}
        end

        context "With a push token that belongs to this instance" do
          let(:instance) {FactoryGirl.create :instance, push_token:token}

          it {response.status.should eq 201}
          it {JSON.parse(response.body)['error_code'].should be_nil}
          it {JSON.parse(response.body)['error_message'].should be_nil}
          it {instance.reload.push_token.should eq token}
        end
      end
    end
  end
end