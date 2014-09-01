require 'rails_helper'

describe :image_choice_question do
  let(:params) {{}}
  let(:setup_questions) {}
  before { setup_questions }
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/questions/image_choice_question", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token, category_id:category_id, title:title, rotate:rotate, choices:choices}}
    let(:auth_token) {}
    let(:category_id) {}
    let(:title) {}
    let(:rotate) {}
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
          let(:choices) {[choice1, choice2, choice3]}
          let(:choice1) {{rotate:true, title:"Choice Title 1", image_url:FactoryGirl.generate(:sample_image_url)}}
          let(:choice2) {{rotate:true, title:"Choice Title 2", image_url:FactoryGirl.generate(:sample_image_url)}}
          let(:choice3) {{rotate:false, title:"Choice Title 3", image_url:FactoryGirl.generate(:sample_image_url)}}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['error_code']).to be_nil}
          it {expect(JSON.parse(response.body)['error_message']).to be_nil}

          describe :question do
            it "should return all question fields" do
              q = JSON.parse(response.body)['question']

              expect(q).to_not be_nil
              expect(q['id']).to_not be_nil
              expect(q['type']).to eq "ImageChoiceQuestion"
              expect(q['title']).to eq "The Title"
              expect(q['rotate']).to eq true
              expect(q['category']['id']).to eq category.id
              expect(q['category']['name']).to eq category.name
              expect(q['comment_count']).to eq 0
              expect(q['response_count']).to eq 0
            end
          end

          describe :choices do
            it "should return all choices and their fields" do
              q = JSON.parse(response.body)['question']
              choices = q['choices']

              expect(choices.count).to eq 3

              expect(choices[0]['choice']['rotate']).to eq true
              expect(choices[0]['choice']['title']).to eq "Choice Title 1"
              expect(choices[0]['choice']['image_url']).not_to be_nil

              expect(choices[1]['choice']['rotate']).to eq true
              expect(choices[1]['choice']['title']).to eq "Choice Title 2"
              expect(choices[0]['choice']['image_url']).not_to be_nil

              expect(choices[2]['choice']['rotate']).to eq false
              expect(choices[2]['choice']['title']).to eq "Choice Title 3"
              expect(choices[0]['choice']['image_url']).not_to be_nil
            end
          end
        end
      end
    end
  end
end