require 'rails_helper'

describe :search do
  let(:params) {{}}
  let(:setup_questions) {}
  before { setup_questions }
  before { post "v/2.0/questions/search", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With all required params" do
    let(:params) {{auth_token: auth_token, search_text: search_text, count: count}}
    let(:search_text) {""}
    let(:count) {10}

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

        context "With some questions" do
          let(:text_choice_question) {FactoryGirl.create :text_choice_question}
          let(:text_choice1) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 1", rotate:true}
          let(:text_choice2) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 2", rotate:true}
          let(:text_choice3) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 3", rotate:false}

          let(:all_questions) { [text_choice_question] }

          let(:setup_questions) {
            all_questions

            text_choice1
            text_choice2
            text_choice3
          }

          it {expect(json['questions']).not_to be_nil}
          it {expect(json['questions'].count).to eq 1}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['error_code']).to be_nil}
          it {expect(JSON.parse(response.body)['error_message']).to be_nil}
        end
      end
    end
  end
end
