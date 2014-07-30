require 'rails_helper'

describe :multiple_choice_question do
  let(:params) {{}}
  let(:setup_questions) {}
  before { setup_questions }
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/questions/multiple_choice_question", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token, category_id:category_id, title:title, min_responses:min_responses, rotate:rotate, choices:choices}}
    let(:auth_token) {}
    let(:category_id) {}
    let(:title) {}
    let(:rotate) {}
    let(:min_responses) {}
    let(:choices) {}

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
          let(:rotate) {true}
          let(:min_responses) {0}
          let(:choices) {[choice1, choice2, choice3]}
          let(:choice1) {{rotate:true, title:"Choice Title 1", muex:false, image_url:FactoryGirl.generate(:sample_image_url)}}
          let(:choice2) {{rotate:true, title:"Choice Title 2", muex:false, image_url:FactoryGirl.generate(:sample_image_url)}}
          let(:choice3) {{rotate:false, title:"Choice Title 3", muex:true, image_url:FactoryGirl.generate(:sample_image_url)}}

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
            it {expect(JSON.parse(response.body)['question']['min_responses']).to eq 0}
            it {expect(JSON.parse(response.body)['question']['comment_count']).to eq 0}
            it {expect(JSON.parse(response.body)['question']['response_count']).to eq 0}
          end

          describe :choices do
            it {expect(JSON.parse(response.body)['question']['choices'].count).to eq 3}

            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['title']).to eq "Choice Title 1"}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['muex']).to eq false}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['image_url']).not_to be_nil}

            it {expect(JSON.parse(response.body)['question']['choices'][1]['choice']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)['question']['choices'][1]['choice']['title']).to eq "Choice Title 2"}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['muex']).to eq false}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['image_url']).not_to be_nil}

            it {expect(JSON.parse(response.body)['question']['choices'][2]['choice']['rotate']).to eq false}
            it {expect(JSON.parse(response.body)['question']['choices'][2]['choice']['title']).to eq "Choice Title 3"}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['muex']).to eq true}
            it {expect(JSON.parse(response.body)['question']['choices'][0]['choice']['image_url']).not_to be_nil}
          end
        end
      end
    end
  end
end
