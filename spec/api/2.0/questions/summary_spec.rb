require 'rails_helper'

describe :summary do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/questions/summary", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "Without the required params" do
    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:params) {{auth_token:auth_token, question_id:question_id}}
    let(:question_id) {0}

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

        question_types = %i[question image_question text_question
          choice_question text_choice_question image_choice_question
          multiple_choice_question star_question percent_question
          order_question]

        # question_types.each do |question_type|
        [question_types.first].each do |question_type|
          context "With a #{question_type.to_s.classify}" do
            let(:question) {FactoryGirl.create question_type}
            let(:question_id) {question.id}

            it {expect(response.status).to eq 201}

            it "should return all summary fields" do
              summary = JSON.parse(response.body)['summary']

              expect(summary.keys).to include('choices')
              expect(summary.keys).to include('response_count')
              expect(summary.keys).to include('view_count')
              expect(summary.keys).to include('comment_count')
              expect(summary.keys).to include('share_count')
              expect(summary.keys).to include('skip_count')
              expect(summary.keys).to include('published_at')
              expect(summary.keys).to include('sponsor')
              expect(summary.keys).to include('creator_id')
              expect(summary.keys).to include('creator_name')
              expect(summary.keys).to include('anonymous')
            end
          end
        end

        context "With a ChoiceQuestion with responses" do
          let(:question) do
            question = FactoryGirl.create :choice_question

            question.choices = FactoryGirl.create_list(
              :choice, 4, question: question)

            question.responses = FactoryGirl.create_list(
              :choice_response, 3, choice: question.choices[1])
            question.responses << FactoryGirl.create(
              :choice_response, choice: question.choices[2])
            question.responses << FactoryGirl.create(
              :choice_response, choice: question.choices[3])

            question
          end
          let(:question_id) {question.id}
          let(:choices_data) { JSON.parse(response.body)['summary']['choices'] }

          it "returns correct choices data" do
            expect(choices_data).to match_array [
              { id: question.choices[0].id, response_ratio: 0 },
              { id: question.choices[1].id, response_ratio: 0.6 },
              { id: question.choices[2].id, response_ratio: 0.2 },
              { id: question.choices[3].id, response_ratio: 0.2 }
            ].map(&:stringify_keys)
          end
        end

        context "with an OrderQuestion with responses" do
          let(:question) do
            question = FactoryGirl.create :order_question

            question.choices = FactoryGirl.create_list(
              :order_choice, 4, question: question)

            question.responses = FactoryGirl.create_list(
              :order_response, 3, choices: question.choices)
            question.responses << FactoryGirl.create(
              :order_response, choices: question.choices.reverse)

            question
          end
          let(:question_id) {question.id}
          let(:choices_data) { JSON.parse(response.body)['summary']['choices'] }

          it "returns correct choices data" do
            expect(choices_data).to match_array [
              { id: question.choices[0].id, response_ratio: 0.75, top_count: 3 },
              { id: question.choices[1].id, response_ratio: 0.0, top_count: 0 },
              { id: question.choices[2].id, response_ratio: 0.0, top_count: 0 },
              { id: question.choices[3].id, response_ratio: 0.25, top_count: 1 }
            ].map(&:stringify_keys)
          end
        end
      end
    end
  end
end
