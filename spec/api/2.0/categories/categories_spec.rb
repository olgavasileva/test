require 'rails_helper'

describe :feed do
  let(:params) {{}}
  let(:setup_categories) {}
  before { setup_categories }
  before { post "v/2.0/categories", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token}}

    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 402}
      it {expect(JSON.parse(response.body)['error_message']).to match /Invalid auth token/}
    end

    context "With an unauthorized instance" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :unauthorized}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 403}
      it {expect(JSON.parse(response.body)['error_message']).to match /Login required/}
    end

    context "With an authorized instance" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :authorized, user:user}

      context "When no user is associated with the instnace" do
        let(:user) {}

        it {expect(response.status).to eq 200}
        it {expect(JSON.parse(response.body)['error_code']).to eq 403}
        it {expect(JSON.parse(response.body)['error_message']).to match /Login required/}
      end

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

          it {expect(JSON.parse(response.body)[1]['category']['id']).to eq c2.id}
          it {expect(JSON.parse(response.body)[1]['category']['name']).to eq "Category 2"}
        end
      end
    end
  end
end