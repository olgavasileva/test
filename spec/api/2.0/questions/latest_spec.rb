require 'rails_helper'
require_relative 'shared_questions'

describe :latest do
  let(:params) {{}}
  let(:setup_questions) {}
  let(:before_api_call) {}
  before { setup_questions }
  before { before_api_call }
  before { post "v/2.0/questions/latest", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With all required params" do
    let(:cursor) {0}
    let(:count) {10}
    let(:params) {{auth_token: auth_token, cursor: cursor, count: count}}

    context "With a logged in user" do
      let(:instance) { FactoryGirl.create(:instance, :logged_in) }
      let(:auth_token) { instance.auth_token }
      let(:user) { instance.user }

      context "With one of each type of question" do
        include_context :shared_questions

        it 'returns the correct data' do
          expect(json['cursor']).not_to be_nil
          expect(json['questions'].count).to eq 5

          expect(response.status).to eq 201
          expect(json['error_code']).to be_nil
          expect(json['error_message']).to be_nil
        end

        describe "Question Output" do
          describe "TextChoiceQuestion" do
            it "should have all required fields" do
              q = json['questions'][4]

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

              expect(choices.map{|c| c['choice']['id']}).to match_array [text_choice1.id, text_choice2.id, text_choice3.id]
              expect(choices.map{|c| c['choice']['title']}).to match_array ["Text Choice 1", "Text Choice 2", "Text Choice 3"]
              expect(choices.map{|c| c['choice']['rotate']}).to match_array [true, true, false]
            end
          end

          describe "MultipleChoiceQuestion" do
            it "should have all required fields" do
              q = json['questions'][3]
              expect(q['id']).to eq multiple_choice_question.id
              expect(q['uuid']).to eq multiple_choice_question.uuid
              expect(q['type']).to eq "MultipleChoiceQuestion"
              expect(q['title']).to eq "Multiple Choice Title"
              expect(q['description']).to eq "Multiple Choice Description"
              expect(q['rotate']).to eq true
              expect(q['min_responses']).to eq 1
              expect(q['max_responses']).to eq 2
              expect(q['comment_count']).to eq 0
              expect(q['response_count']).to eq 0
              expect(q['creator_name']).to eq multiple_choice_question.user.username
              expect(q['creator_id']).to eq multiple_choice_question.user.id
              expect(q['image_url']).not_to be_nil
              expect(q['created_at']).to_not be_nil


              choices = q['choices']

              expect(choices.count).to eq 3

              expect(choices.map{|c| c['choice']['id']}).to match_array [multiple_choice1.id, multiple_choice2.id, multiple_choice3.id]
              expect(choices.map{|c| c['choice']['title']}).to match_array ["Multiple Choice 1", "Multiple Choice 2", "Multiple Choice 3"]
              expect(choices.map{|c| c['choice']['rotate']}).to match_array [true, true, false]
              expect(choices.map{|c| c['choice']['muex']}).to match_array [true, true, false]

              expect(choices[0]['choice']['image_url']).not_to be_nil
              expect(choices[1]['choice']['image_url']).not_to be_nil
              expect(choices[2]['choice']['image_url']).not_to be_nil
            end
          end

          describe "ImageChoiceQuestion" do
            it "should have all required fields" do
              q = json['questions'][2]
              expect(q['id']).to eq image_choice_question.id
              expect(q['uuid']).to eq image_choice_question.uuid
              expect(q['type']).to eq "ImageChoiceQuestion"
              expect(q['title']).to eq "Image Choice Title"
              expect(q['description']).to eq "Image Choice Description"
              expect(q['rotate']).to eq true
              expect(q['category']['name']).to eq "Category 2"
              expect(q['comment_count']).to eq 0
              expect(q['response_count']).to eq 0
              expect(q['created_at']).to_not be_nil
              expect(q['image_url']).not_to be_nil


              choices = q['choices']

              expect(choices.count).to eq 2

              expect(choices.map{|c| c['choice']['id']}).to match_array [image_choice1.id, image_choice2.id]
              expect(choices.map{|c| c['choice']['title']}).to match_array ["Image Choice 1", "Image Choice 2"]
              expect(choices.map{|c| c['choice']['rotate']}).to match_array [false, false]

              expect(choices[0]['choice']['image_url']).not_to be_nil
              expect(choices[1]['choice']['image_url']).not_to be_nil
            end
          end

          describe "OrderQuestion" do
            it "should have all required fields" do
              q = json['questions'][1]
              expect(q['id']).to eq order_question.id
              expect(q['uuid']).to eq order_question.uuid
              expect(q['type']).to eq "OrderQuestion"
              expect(q['title']).to eq "Order Title"
              expect(q['description']).to eq "Order Description"
              expect(q['rotate']).to eq true
              expect(q['category']['name']).to eq "Category 1"
              expect(q['comment_count']).to eq 0
              expect(q['response_count']).to eq 0
              expect(q['image_url']).not_to be_nil
              expect(q['created_at']).to_not be_nil


              choices = q['choices']

              expect(choices.count).to eq 3

              expect(choices.map{|c| c['choice']['id']}).to match_array [order_choice1.id, order_choice2.id, order_choice3.id]
              expect(choices.map{|c| c['choice']['title']}).to match_array ["Order Choice 1", "Order Choice 2", "Order Choice 3"]
              expect(choices.map{|c| c['choice']['rotate']}).to match_array [true, true, false]

              expect(choices[0]['choice']['image_url']).not_to be_nil
              expect(choices[1]['choice']['image_url']).not_to be_nil
              expect(choices[2]['choice']['image_url']).not_to be_nil
            end
          end

          describe "TextQuestion" do
            it "should have all required fields" do
              q = json['questions'][0]
              expect(q['id']).to eq text_question.id
              expect(q['uuid']).to eq text_question.uuid
              expect(q['type']).to eq "TextQuestion"
              expect(q['title']).to eq "Text Title"
              expect(q['description']).to eq "Text Description"
              expect(q['category']['name']).to eq "Category 1"
              expect(q['image_url']).not_to be_nil
              expect(q['text_type']).to eq "freeform"
              expect(q['min_characters']).to eq 1
              expect(q['max_characters']).to eq 100
              expect(q['comment_count']).to eq 0
              expect(q['response_count']).to eq 0
              expect(q['created_at']).to_not be_nil
            end
          end
        end

        context "when the params include category_ids" do
          let(:category_ids) { [category1.id, category2.id] }
          let(:params) {{auth_token: auth_token, cursor: cursor, count: count, category_ids: category_ids}}

          it 'returns only questions for the given categories' do
            expect(json['questions'].count).to eq(5)
          end
        end

        context "When the params include community_ids" do
          let(:c1) { FactoryGirl.create(:community) }
          let(:c2) { FactoryGirl.create(:community) }
          let(:community_ids) { [c1.id] }
          let(:params) {{auth_token: auth_token, cursor: cursor, count: count, community_ids: community_ids}}

          let(:before_api_call) do
            q1.update_attributes(target: FactoryGirl.create(:consumer_target, community_ids: [c1.id]))
            q2.update_attributes(target: FactoryGirl.create(:consumer_target, community_ids: [c1.id]))
            q3.update_attributes(target: FactoryGirl.create(:consumer_target, community_ids: [c2.id]))
          end

          it 'returns only questions for the given communities' do
            ids = json['questions'].map { |q| q['id'] }
            expect(ids.sort).to eq([q1.id, q2.id])
          end
        end

        context "When the params include user_ids" do
          let(:user_ids) { [@question_user_2.id] }
          let(:params) do
            {
              auth_token: auth_token,
              cursor: cursor,
              count: count,
              user_ids: user_ids
            }
          end

          it 'returns only questions for the given user' do
            ids = json['questions'].map { |q| q['id'] }
            expect(ids).to eq([@multiple_choice_question.id])
          end
        end

        context "When the params include community_ids and category_ids" do
          let(:params) {{auth_token: auth_token, cursor: cursor, count: count, category_ids: category_ids, community_ids: community_ids}}

          context "When filtering on category1, which has q1, q4, and q5" do
            let(:category_ids) {[category1.id]}
            let(:c1) {FactoryGirl.create :community}

            context "When q1 and q2 were targeted at community 1" do
              let(:before_api_call) do
                q1.update_attributes target: FactoryGirl.create(:consumer_target, community_ids: [c1.id])
                q2.update_attributes target: FactoryGirl.create(:consumer_target, community_ids: [c1.id])
              end

              context "When filtering on community 1" do
                let(:community_ids) {[c1.id]}

                it {expect(json['questions'].map{|q| q['id']}).to match_array [q1.id]}
              end
            end
          end
        end

        context "When the user has answered the text choice question" do
          let(:text_choice_response) {FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1}
          let(:user) {text_choice_response.user}

          it 'returns the correct response' do
            expect(json['questions'].count).to eq all_questions.count
            expect(json['questions'][3]['id']).to eq multiple_choice_question.id
            expect(json['questions'][2]['id']).to eq image_choice_question.id
          end
        end

        context "When the text_choice_question has been responded to by another user" do
          context "With no comment" do
            let(:before_api_call) {FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1}

            it 'returns the correct response' do
              expect(json['questions'].count).to eq all_questions.count
              expect(json['questions'][4]['id']).to eq text_choice_question.id
              expect(json['questions'][4]['comment_count']).to eq 0
              expect(json['questions'][4]['response_count']).to eq 1
            end
          end

          context "With a comment" do
            let(:before_api_call) {
              response = FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1
              response.create_comment user:response.user, body:"Some comment"
            }

            it 'returns the correct response' do
              expect(json['questions'].count).to eq all_questions.count
              expect(json['questions'][4]['id']).to eq text_choice_question.id
              expect(json['questions'][4]['comment_count']).to eq 1
              expect(json['questions'][4]['response_count']).to eq 1
            end
          end
        end

        describe "Cursor and count" do
          context "When the cursor is 0 and the count is 2" do
            let(:cursor) {0}
            let(:count) {2}

            it 'returns the correct response' do
              expect(json['questions'].count).to eq 2
              expect(json['questions'].map{|q| q["id"]}).to eq [q5.id, q4.id]
              expect(json['cursor']).to eq q4.id
            end
          end

          context "When the cursor is the id of the 2nd newest question and count is 2" do
            let(:cursor) {q4.id}
            let(:count) {2}

            it 'returns the correct response' do
              expect(json['questions'].count).to eq 2
              expect(json['questions'].map{|q| q["id"]}).to eq [q3.id, q2.id]
              expect(json['cursor']).to eq q2.id
            end


            context "When count is greater than the number of questions remaining" do
              let(:count) {200}

              it 'returns the correct response' do
                expect(json['questions'].count).to eq 3
                expect(json['questions'].map{|q| q["id"]}).to eq [q3.id, q2.id, q1.id]
                expect(json['cursor']).to eq q1.id
              end
            end

            context "When the cursor is the last item in the list" do
              let(:cursor) {q1.id}
              let(:count) {2}

              it 'returns the correct response' do
                expect(json['questions'].count).to eq 0
                expect(json['questions']).to eq []
                expect(json['cursor']).to eq 0
              end
            end
          end
        end
      end
    end
  end
end
