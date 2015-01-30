require 'rails_helper'

describe :first_launch do
  def get_instance instance_token = nil
    device_vendor_identifier = FactoryGirl.generate(:device_vendor_identifier)
    api_signature = Digest::SHA2.hexdigest(device_vendor_identifier + ENV["api_shared_secret"].to_s)

    params = {
      instance_token: instance_token,
      api_signature: api_signature,
      app_version: "1.2",
      device_vendor_identifier: device_vendor_identifier,
      platform: 'ios',
      manufacturer: "apple",
      model: "iPhone 5s",
      os_version: 'iOS 7.1'
    }

    post "v/2.0/instances", params
    expect(JSON.parse(response.body)['error_message']).to be_nil
    expect(response.status).to eq 201

    JSON.parse(response.body)['instance_token']
  end

  def register_new_user instance_token
    params = {
      instance_token: instance_token,
      email: FactoryGirl.generate(:email_address),
      username: FactoryGirl.generate(:username),
      password: FactoryGirl.generate(:password),
      name: FactoryGirl.generate(:name),
      birthdate: FactoryGirl.generate(:birthdate),
      gender: FactoryGirl.generate(:gender)
    }

    post "v/2.0/users/register", params
    expect(JSON.parse(response.body)['error_message']).to be_nil
    expect(response.status).to eq 201

    JSON.parse(response.body)['auth_token']
  end

  def login_existing_user instance_token
    password = FactoryGirl.generate :password
    user = FactoryGirl.create :user, password:password, password_confirmation:password

    params = {
      instance_token: instance_token,
      email: user.email,
      password: password
    }

    post "v/2.0/users/login", params
    expect(JSON.parse(response.body)['error_message']).to be_nil
    expect(response.status).to eq 201

    JSON.parse(response.body)['auth_token']
  end

  def add_push_token instance_token
    push_token = FactoryGirl.generate :apn_token

    params = {
      instance_token: instance_token,
      token: push_token,
      environment: 'development'
    }

    post "v/2.0/instances/push_token", params
    expect(JSON.parse(response.body)['error_message']).to be_nil
    expect(response.status).to eq 201

    push_token
  end

  describe "When we supply the push token shouldn't matter as long as it's after getting the instance" do
    context "After calling the get instance API with no existing instance_token" do
      let!(:instance_token) {get_instance}

      it "Should work when registering then adding the token" do
        auth_token = register_new_user instance_token
        push_token = add_push_token instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end

      it "Should work when adding the token then registering" do
        push_token = add_push_token instance_token
        auth_token = register_new_user instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end

      it "Should work when logging in then adding the token" do
        auth_token = login_existing_user instance_token
        push_token = add_push_token instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end

      it "Should work when adding the token then logging in" do
        push_token = add_push_token instance_token
        auth_token = login_existing_user instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end
    end

    context "After calling the get instance API with an existing instance_token" do
      let(:existing_instance) {FactoryGirl.create :instance}
      let!(:instance_token) {get_instance existing_instance.uuid}

      it "Should work when registering then adding the token" do
        auth_token = register_new_user instance_token
        push_token = add_push_token instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end

      it "Should work when adding the token then registering" do
        push_token = add_push_token instance_token
        auth_token = register_new_user instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end

      it "Should work when logging in then adding the token" do
        auth_token = login_existing_user instance_token
        push_token = add_push_token instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end

      it "Should work when adding the token then logging in" do
        push_token = add_push_token instance_token
        auth_token = login_existing_user instance_token

        instance_from_uuid = Instance.find_by uuid:instance_token
        instance_from_auth_token = Instance.find_by auth_token:auth_token
        expect(instance_from_auth_token).to eq instance_from_uuid
        expect(instance_from_uuid.push_token).to eq push_token
      end
    end
  end
end