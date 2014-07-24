require 'rails_helper'

describe :feed do
  let(:params) {{}}
  let(:setup_questions) {}
  before { setup_questions }
  before { post "v/2.0/questions/feed", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

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

        context "With no questions" do
          it {expect(JSON.parse(response.body)).to eq []}
        end

        context "With one of each type of question" do
          let(:image) {FactoryGirl.generate :image}
          let(:category1) {FactoryGirl.create :category, name:"Category 1"}
          let(:category2) {FactoryGirl.create :category, name:"Category 2"}

          let(:text_choice_question) {FactoryGirl.create :text_choice_question, category:category1, title:"Text Choice Title", description:"Text Choice Description", image:image, rotate:true, created_at:Date.today}
          let(:text_choice1) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 1", rotate:true}
          let(:text_choice2) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 2", rotate:true}
          let(:text_choice3) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 3", rotate:false}

          let(:multiple_choice_question) {FactoryGirl.create :multiple_choice_question, category:category2, title:"Multiple Choice Title", description:"Multiple Choice Description", rotate:true, min_responses:1, max_responses:2, created_at:Date.today - 1.day}
          let(:multiple_choice1) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 1", rotate:true, muex:true}
          let(:multiple_choice2) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 2", rotate:true, muex:false}
          let(:multiple_choice3) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 3", rotate:false, muex:true}

          let(:image_choice_question) {FactoryGirl.create :image_choice_question, category:category2, title:"Image Choice Title", description:"Image Choice Description", rotate:false, created_at:Date.today - 2.days}
          let(:image_choice1) {FactoryGirl.create :image_choice, question:image_choice_question, title:"Image Choice 1", image:image, rotate:false}
          let(:image_choice2) {FactoryGirl.create :image_choice, question:image_choice_question, title:"Image Choice 2", image:image, rotate:false}

          let(:setup_questions) {
            text_choice_question
            text_choice1
            text_choice2
            text_choice3

            multiple_choice_question
            multiple_choice1
            multiple_choice2
            multiple_choice3

            image_choice_question
            image_choice1
            image_choice2
          }

          describe "Question Output" do
            it {expect(JSON.parse(response.body).count).to eq 3}

            it {expect(JSON.parse(response.body)[0]['question']['id']).to eq text_choice_question.id}
            it {expect(JSON.parse(response.body)[0]['question']['type']).to eq "TextChoiceQuestion"}
            it {expect(JSON.parse(response.body)[0]['question']['title']).to eq "Text Choice Title"}
            it {expect(JSON.parse(response.body)[0]['question']['description']).to eq "Text Choice Description"}
            it {expect(JSON.parse(response.body)[0]['question']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)[0]['question']['category']['name']).to eq "Category 1"}
            it {expect(JSON.parse(response.body)[0]['question']['image_url']).not_to be_nil}

            it {expect(JSON.parse(response.body)[1]['question']['id']).to eq multiple_choice_question.id}
            it {expect(JSON.parse(response.body)[1]['question']['type']).to eq "MultipleChoiceQuestion"}
            it {expect(JSON.parse(response.body)[1]['question']['title']).to eq "Multiple Choice Title"}
            it {expect(JSON.parse(response.body)[1]['question']['description']).to eq "Multiple Choice Description"}
            it {expect(JSON.parse(response.body)[1]['question']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)[1]['question']['min_responses']).to eq 1}
            it {expect(JSON.parse(response.body)[1]['question']['max_responses']).to eq 2}

            it {expect(JSON.parse(response.body)[2]['question']['id']).to eq image_choice_question.id}
            it {expect(JSON.parse(response.body)[2]['question']['type']).to eq "ImageChoiceQuestion"}
            it {expect(JSON.parse(response.body)[2]['question']['title']).to eq "Image Choice Title"}
            it {expect(JSON.parse(response.body)[2]['question']['description']).to eq "Image Choice Description"}
            it {expect(JSON.parse(response.body)[2]['question']['rotate']).to eq false}
            it {expect(JSON.parse(response.body)[2]['question']['category']['name']).to eq "Category 2"}
          end

          describe "Text Choice output" do
            it {expect(JSON.parse(response.body)[0]['question']['choices'].count).to eq 3}

            it {expect(JSON.parse(response.body)[0]['question']['choices'][0]['choice']['id']).to eq text_choice1.id}
            it {expect(JSON.parse(response.body)[0]['question']['choices'][0]['choice']['title']).to eq "Text Choice 1"}
            it {expect(JSON.parse(response.body)[0]['question']['choices'][0]['choice']['rotate']).to eq true}

            it {expect(JSON.parse(response.body)[0]['question']['choices'][1]['choice']['id']).to eq text_choice2.id}
            it {expect(JSON.parse(response.body)[0]['question']['choices'][1]['choice']['title']).to eq "Text Choice 2"}
            it {expect(JSON.parse(response.body)[0]['question']['choices'][1]['choice']['rotate']).to eq true}

            it {expect(JSON.parse(response.body)[0]['question']['choices'][2]['choice']['id']).to eq text_choice3.id}
            it {expect(JSON.parse(response.body)[0]['question']['choices'][2]['choice']['title']).to eq "Text Choice 3"}
            it {expect(JSON.parse(response.body)[0]['question']['choices'][2]['choice']['rotate']).to eq false}
          end

          describe "Multiple Choice Output" do
            it {expect(JSON.parse(response.body)[1]['question']['choices'].count).to eq 3}

            it {expect(JSON.parse(response.body)[1]['question']['choices'][0]['choice']['id']).to eq multiple_choice1.id}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][0]['choice']['title']).to eq "Multiple Choice 1"}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][0]['choice']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][0]['choice']['muex']).to eq true}

            it {expect(JSON.parse(response.body)[1]['question']['choices'][1]['choice']['id']).to eq multiple_choice2.id}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][1]['choice']['title']).to eq "Multiple Choice 2"}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][1]['choice']['rotate']).to eq true}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][1]['choice']['muex']).to eq false}

            it {expect(JSON.parse(response.body)[1]['question']['choices'][2]['choice']['id']).to eq multiple_choice3.id}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][2]['choice']['title']).to eq "Multiple Choice 3"}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][2]['choice']['rotate']).to eq false}
            it {expect(JSON.parse(response.body)[1]['question']['choices'][2]['choice']['muex']).to eq true}
          end

          describe "Image Choice Output" do
            it {expect(JSON.parse(response.body)[2]['question']['choices'].count).to eq 2}

            it {expect(JSON.parse(response.body)[2]['question']['choices'][0]['choice']['id']).to eq image_choice1.id}
            it {expect(JSON.parse(response.body)[2]['question']['choices'][0]['choice']['title']).to eq "Image Choice 1"}
            it {expect(JSON.parse(response.body)[2]['question']['choices'][0]['choice']['rotate']).to eq false}
            it {expect(JSON.parse(response.body)[2]['question']['choices'][0]['choice']['image_url']).not_to be_nil}

            it {expect(JSON.parse(response.body)[2]['question']['choices'][1]['choice']['id']).to eq image_choice2.id}
            it {expect(JSON.parse(response.body)[2]['question']['choices'][1]['choice']['title']).to eq "Image Choice 2"}
            it {expect(JSON.parse(response.body)[2]['question']['choices'][1]['choice']['rotate']).to eq false}
            it {expect(JSON.parse(response.body)[2]['question']['choices'][1]['choice']['image_url']).not_to be_nil}
          end

          it {expect(response.body).to eq "Troy"}

          context "When the user has answered the text choice question" do
            let(:text_choice_response) {FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1}
            let(:user) {text_choice_response.user}

            it {expect(JSON.parse(response.body).count).to eq 2}
            it {expect(JSON.parse(response.body)[0]['question']['id']).to eq multiple_choice_question.id}
            it {expect(JSON.parse(response.body)[1]['question']['id']).to eq image_choice_question.id}
          end
        end
      end
    end
  end
end