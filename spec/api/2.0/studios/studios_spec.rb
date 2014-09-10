require 'rails_helper'

describe :studios do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/studios/#{studio_id}"}

  context "Invalid Studio ID" do
    let (:studio_id) { "1" }
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to be_present}
    it {expect(JSON.parse(response.body)['error_message']).to eq "Studio with ID 1 not found"}
  end

  context "Valid Studio ID" do
    let(:studio) {FactoryGirl.create :studio, display_name: "Test Studio"}
    let(:studio_id) {studio.id}
    it {expect(response.status).to eq 201}
    it {expect(JSON.parse(response.body)).to be_present}
    it {expect(JSON.parse(response.body)['studio']['display_name']).to eq "Test Studio"}
  end
end
