require 'rails_helper'

describe :location do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:common_params) { {
    instance_token: instance.uuid,
    auth_token: instance.auth_token,
    accuracy: 0
  } }
  let(:response_body) { JSON.parse(response.body) }

  before { post 'v/2.0/users/location', params }

  shared_examples :success do
    it "is successful" do
      expect(response.status).to eq 201
    end

    it "responds with no data" do
      expect(response_body.keys).to be_blank
    end

    it "sets current user's latitude and longitude" do
      expect(instance.user.reload.latitude).to_not be_nil
      expect(instance.user.reload.longitude).to_not be_nil
    end
  end

  shared_examples :fail do
    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end


  context "without location params" do
    let(:params) { common_params }

    it_behaves_like :fail
  end

  context "with IP source" do
    let(:params) { common_params.merge(source: 'IP') }

    it_behaves_like :success
  end

  context "with gps source" do
    context "lacking longitude and latitude" do
      let(:params) { common_params.merge(source: 'gps') }

      it_behaves_like :fail
    end

    context "with longitude and latitude" do
      let(:params) { common_params.merge(source: 'gps',
                                         longitude: 1,
                                         latitude: 2) }

      it_behaves_like :success
    end
  end
end

