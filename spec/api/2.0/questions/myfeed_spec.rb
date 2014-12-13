require 'rails_helper'
require_relative 'shared_questions'

describe :myfeed do
  let(:params) {{}}
  let(:setup_questions) {}
  let(:setup_targeting) {}
  let(:before_api_call) {}
  before { setup_questions }
  before { setup_targeting }
  before { before_api_call }
  before { post "v/2.0/questions/myfeed", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

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

        context "With one of each type of question not targeted to this user" do
          include_context :shared_questions

          it {expect(json).not_to be_nil}
          it {expect(json.class).to eq Array}
          it {expect(json.count).to eq 0}

          context "With two of the questions targeted to this user" do
            let(:setup_targeting) {
              user.feed_items.find_by_question_id(q1).update_attribute :targeted, true
              user.feed_items.find_by_question_id(q2).update_attribute :targeted, true
            }

            it {expect(json).not_to be_nil}
            it {expect(json.class).to eq Array}
            it {expect(json.count).to eq 2}
            it {expect(json[0]['question']).to be_present}
            it {expect(json[1]['question']).to be_present}

            it {expect(response.status).to eq 201}

            describe "TextChoiceQuestion" do
              it "should have all required fields" do
                q = json[1]['question']

                expect(q['id']).to eq text_choice_question.id
                expect(q['uuid']).to eq text_choice_question.uuid
                expect(q['type']).to eq "TextChoiceQuestion"
                expect(q['title']).to eq "Text Choice Title"
                expect(q['description']).to eq "Text Choice Description"
                expect(q['rotate']).to eq true
                expect(q['category']['name']).to eq "Category 1"
                expect(q['created_at']).to_not be_nil
                expect(q['image_url']).not_to be_nil
                expect(q['comment_count']).to eq 0
                expect(q['response_count']).to eq 0


                choices = q['choices']

                expect(choices.count).to eq 3

                expect(choices[0]['choice']['id']).to eq text_choice1.id
                expect(choices[0]['choice']['title']).to eq "Text Choice 1"
                expect(choices[0]['choice']['rotate']).to eq true

                expect(choices[1]['choice']['id']).to eq text_choice2.id
                expect(choices[1]['choice']['title']).to eq "Text Choice 2"
                expect(choices[1]['choice']['rotate']).to eq true

                expect(choices[2]['choice']['id']).to eq text_choice3.id
                expect(choices[2]['choice']['title']).to eq "Text Choice 3"
                expect(choices[2]['choice']['rotate']).to eq false
              end
            end
          end
        end
      end
    end
  end
end
