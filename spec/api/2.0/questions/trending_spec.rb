require 'rails_helper'

describe :trending do
  let(:params) {{}}
  let(:setup_questions) {}
  before { setup_questions }
  before { post "v/2.0/questions/trending", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With all required params" do
    let(:params) {{auth_token: auth_token, index: index, count: count}}
    let(:index) {0}
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
          let(:q1) {FactoryGirl.create :text_choice_question, trending_index: 1}
          let(:c1) {FactoryGirl.create :text_choice, question:q1, title:"Text Choice 1", rotate:true}
          let(:c2) {FactoryGirl.create :text_choice, question:q1, title:"Text Choice 2", rotate:true}
          let(:c3) {FactoryGirl.create :text_choice, question:q1, title:"Text Choice 3", rotate:false}
          let(:q3) {FactoryGirl.create :text_choice_question, trending_index: 3}
          let(:q2) {FactoryGirl.create :text_choice_question, trending_index: 2}

          let(:all_questions) { [q1,q2,q3] }

          let(:setup_questions) {
            all_questions

            c1
            c2
            c3
          }

          it {expect(response.status).to eq 201}
          it {expect(json).not_to be_nil}
          it {expect(json.class).to eq Array}
          it {expect(json.count).to eq 3}
          it {expect(json[0]['question']).to be_present}
          it {expect(json.map{|q|q["question"]["id"]}).to eq [q3.id, q2.id, q1.id]}
        end
      end
    end
  end
end
