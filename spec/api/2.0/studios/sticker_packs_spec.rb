require 'rails_helper'

describe :sticker_pack do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/studios/#{studio_id}/sticker_packs", {},{"CONTENT_TYPE" => "application/json"}}

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

    context "No sticker packs" do
      it {expect(response.status).to eq 201}
      it {expect(JSON.parse(response.body)["sticker_packs"]).to eq []}
    end

    context "Two sticker packs" do
      let(:sticker_pack_1) {FactoryGirl.create :sticker_pack, display_name:"Test Sticker Pack 1"}
      let(:sticker_pack_2) {FactoryGirl.create :sticker_pack, display_name:"Test Sticker Pack 2"}
      let(:before_api_call) {studio.sticker_packs += [sticker_pack_1, sticker_pack_2]}

      it {expect(JSON.parse(response.body)["sticker_packs"].count).to eq 2}
      it {expect(JSON.parse(response.body)["sticker_packs"][0].keys).to match_array ["id", "display_name", "max_on_canvas", "updated_at", "header_icon_url", "sort_order"]}
      it {expect(JSON.parse(response.body)["sticker_packs"][1].keys).to match_array ["id", "display_name", "max_on_canvas", "updated_at", "header_icon_url", "sort_order"]}
      it {expect(JSON.parse(response.body)["sticker_packs"][0]['display_name']).to eq "Test Sticker Pack 1"}
      it {expect(JSON.parse(response.body)["sticker_packs"][1]['display_name']).to eq "Test Sticker Pack 2"}
    end
  end
end
