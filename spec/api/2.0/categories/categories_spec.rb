require 'rails_helper'

describe :categories do
  let(:params) {{}}
  let(:setup_categories) {}
  before { setup_categories }
  before { post "v/2.0/categories", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With all required params" do
    context "When a user is associated with the instnace" do
      let(:user) {FactoryGirl.create :user}

      context "With no categories" do
        it {expect(JSON.parse(response.body)).to eq []}
      end

      context "With two categories" do
        let(:c1) {FactoryGirl.create :category, name:"Category 1"}
        let(:c2) {FactoryGirl.create :category, name:"Category 2"}
        let(:setup_categories) do
          c1
          c2
        end

        it {expect(JSON.parse(response.body).count).to eq 2}

        it {expect(JSON.parse(response.body)[0]['category']['id']).to eq c1.id}
        it {expect(JSON.parse(response.body)[0]['category']['name']).to eq "Category 1"}
        it {expect(JSON.parse(response.body)[0]['category'].keys).to include 'icon_url'}

        it {expect(JSON.parse(response.body)[1]['category']['id']).to eq c2.id}
        it {expect(JSON.parse(response.body)[1]['category']['name']).to eq "Category 2"}
        it {expect(JSON.parse(response.body)[1]['category'].keys).to include 'icon_url'}
      end
    end
  end
end
