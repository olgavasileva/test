require 'spec_helper'

describe :register do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "api/v/2.0/users/register", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With all required params" do
    let(:params) {{username: username, name:name, email:email, password:password, udid:udid, device_type:device_type, os_version:os_version}}

    let(:username) {FactoryGirl.generate :username}
    let(:name) {FactoryGirl.generate :name}
    let(:email) {FactoryGirl.generate :email}
    let(:password) {FactoryGirl.generate :password}
    let(:udid) {FactoryGirl.generate :udid}
    let(:device_type) {FactoryGirl.generate :device_type}
    let(:os_version) {FactoryGirl.generate :os_version}

    it {response.status.should eq 201}
    it {JSON.parse(response.body).should_not be_nil}
    it {JSON.parse(response.body)['error_code'].should be_nil}
    it {JSON.parse(response.body)['error_message'].should be_nil}


end
