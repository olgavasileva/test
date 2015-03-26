require 'rails_helper'

RSpec.describe TwoCents::Categories, 'POST /categories' do
  let(:params) { Hash.new }
  subject { post "v/2.0/categories", params }

  context "with no categories" do
    it "returns an empty array" do
      subject
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  context "with two categories" do
    let!(:c1) { FactoryGirl.create(:category, name:"Category 1") }
    let!(:c2) { FactoryGirl.create(:category, name:"Category 2") }

    it "returns the correct data" do
      subject
      json = JSON.parse(response.body)

      expect(json.count).to eq(2)

      expect(json[0]['category']['id']).to eq(c1.id)
      expect(json[0]['category']['name']).to eq(c1.name)
      expect(json[0]['category'].keys).to include('icon_url')

      expect(json[1]['category']['id']).to eq(c2.id)
      expect(json[1]['category']['name']).to eq(c2.name)
      expect(json[1]['category'].keys).to include('icon_url')
    end
  end
end
