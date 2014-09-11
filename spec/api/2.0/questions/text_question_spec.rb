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
    let(:params) {{auth_token:auth_token, category_id:category_id, title:title, image_url:image_url, text_type:text_type, min_characters:min_characters, max_characters:max_characters, targets: targets }}
    let(:auth_token) {}
    let(:category_id) {}
    let(:title) {}
    let(:image_url) {}
    let(:text_type) {}
    let(:min_characters) {}
    let(:max_characters) {}
    let(:targets) {}

    context "Witout a valid text_type value" do
      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)).to_not be_nil}
      it {expect(JSON.parse(response.body)['error_code']).to eq 400}
      it {expect(JSON.parse(response.body)['error_message']).to match /.+ does not have a valid value/}
    end

    context "With a valid text_type value" do
      let(:text_type) {'freeform'}

      context "With an invalid auth token" do
        let(:auth_token) {"INVALID"}
        let(:text_type) {"freeform"}

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
            let(:min_characters) {10}
            let(:max_characters) {100}

            it {expect(response.status).to eq 201}
            it {expect(JSON.parse(response.body)['error_code']).to be_nil}
            it {expect(JSON.parse(response.body)['error_message']).to be_nil}

            describe :question do
              it "should return all question fields" do
                q = JSON.parse(response.body)['question']

                expect(q).to_not be_nil
                expect(q['id']).to_not be_nil
                expect(q['type']).to eq "TextQuestion"
                expect(q['title']).to eq "The Title"
                expect(q['category']['id']).to eq category.id
                expect(q['category']['name']).to eq category.name
                expect(q['image_url']).not_to be_nil
                expect(q['text_type']).to eq 'freeform'
                expect(q['min_characters']).to eq 10
                expect(q['max_characters']).to eq 100
                expect(q['comment_count']).to eq 0
                expect(q['response_count']).to eq 0
              end
            end
          end
        end
      end
    end
  end
end
