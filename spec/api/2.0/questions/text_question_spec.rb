require 'rails_helper'

describe :text_question do
  let(:params) {{}}
  let(:setup_questions) {}
  before { setup_questions }
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/questions/text_question", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token, category_id:category_id, title:title, image_url:image_url, rotate:rotate, text_type:text_type, min_characters:min_characters, max_characters:max_characters }}
    let(:auth_token) {}
    let(:category_id) {}
    let(:title) {}
    let(:image_url) {}
    let(:text_type) {}
    let(:min_characters) {}
    let(:max_characters) {}

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

        context "With valid field values" do
          let(:category) {FactoryGirl.create :category}
          let(:category_id) {category.id}
          let(:title) {"The Title"}
          let(:image_url) {FactoryGirl.generate :sample_image_url}
          let(:text_type) {'freeform'}
          let(:min_characters) {10}
          let(:max_characters) {100}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['error_code']).to be_nil}
          it {expect(JSON.parse(response.body)['error_message']).to be_nil}

          describe :question do
            it {expect(JSON.parse(response.body)['question']).to_not be_nil}
            it {expect(JSON.parse(response.body)['question']['id']).to_not be_nil}
            it {expect(JSON.parse(response.body)['question']['type']).to eq "TextChoiceQuestion"}
            it {expect(JSON.parse(response.body)['question']['title']).to eq "The Title"}
            it {expect(JSON.parse(response.body)['question']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)['question']['category']['id']).to eq category.id}
            it {expect(JSON.parse(response.body)['question']['category']['name']).to eq category.name}
            it {expect(JSON.parse(response.body)['question']['image_url']).not_to be_nil}
            it {expect(JSON.parse(response.body)['question']['text_type']).to eq ;'freeform'}
            it {expect(JSON.parse(response.body)['question']['min_characters']).to eq 10}
            it {expect(JSON.parse(response.body)['question']['max_characters']).to eq 100}
            it {expect(JSON.parse(response.body)['question']['comment_count']).to eq 0}
            it {expect(JSON.parse(response.body)['question']['response_count']).to eq 0}
          end
        end
      end
    end
  end
end
