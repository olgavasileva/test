require 'rails_helper'
require_relative 'shared_create_examples'

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
    let(:params) do
      {
        auth_token: auth_token,
        category_id: category_id,
        title: title,
        image_url: image_url,
        text_type: text_type,
        min_characters: min_characters,
        max_characters: max_characters,
        targets: targets,
        anonymous: anonymous,
        tag_list: tag_list
      }
    end

    let(:auth_token) {}
    let(:category_id) {}
    let(:title) {}
    let(:image_url) {}
    let(:text_type) {}
    let(:min_characters) {}
    let(:max_characters) {}
    let(:targets) {}
    let(:anonymous) {}
    let(:tag_list) { ['test', 'tag'] }

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

      context "With a logged in user" do
        let(:auth_token) {instance.auth_token}
        let(:instance) {FactoryGirl.create :instance, :logged_in}
        let(:user) {instance.user}

        context "With valid field values" do
          let(:category) {FactoryGirl.create :category}
          let(:category_id) {category.id}
          let(:title) {"The Title"}
          let(:image_url) {FactoryGirl.generate :sample_image_url}
          let(:min_characters) {10}
          let(:max_characters) {100}

          it {expect(response.status).to eq 201}

          it "should return all question fields" do
            q = JSON.parse(response.body)['question']

            expect(q).to_not be_nil
            expect(q['id']).to_not be_nil
            expect(q['uuid']).not_to be_nil
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
            expect(q['creator_id']).to eq user.id
            expect(q['creator_name']).to eq user.username
            expect(q['member_community_ids']).to be_an Array
            expect(q['tags']).to eq(tag_list.map{|t| "##{t}" })
          end

          it_behaves_like :uses_targets
          it_behaves_like :uses_anonymous
          it_behaves_like :uses_survey
        end
      end
    end
  end
end
