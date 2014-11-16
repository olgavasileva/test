require 'rails_helper'

describe :sticker_pack do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/studios/#{studio_id}/sticker_packs/#{sticker_pack_id}", {},{"CONTENT_TYPE" => "application/json"}}

  context "Invalid Studio ID" do
    let (:studio_id) { "1" }
    let (:sticker_pack_id) { "1" }
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to be_present}
    it {expect(JSON.parse(response.body)['error_message']).to eq "Studio with ID 1 not found"}
  end

  context "Valid Studio ID" do
    let(:studio) {FactoryGirl.create :studio}
    let(:studio_id) {studio.id}

    context "Invalid Sticker Pack ID" do
      let (:sticker_pack_id) { "1" }
      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)).to be_present}
      it {expect(JSON.parse(response.body)['error_message']).to eq "Sticker pack with ID #{sticker_pack_id} not found"}
    end

    context "Valid Sticker Pack ID" do
      let(:sticker_pack) {FactoryGirl.create :sticker_pack, display_name:"Test Sticker Pack"}
      let(:sticker_pack_id) {sticker_pack.id}
      let(:before_api_call) {studio.sticker_packs << sticker_pack}

      it {expect(response.status).to eq 201}
      it {expect(JSON.parse(response.body).keys).to match_array ["id", "display_name", "max_on_canvas", "updated_at", "header_icon_url"] }
      it {expect(JSON.parse(response.body)).to be_present}
      it {expect(JSON.parse(response.body)['display_name']).to eq "Test Sticker Pack"}
    end
  end
end
