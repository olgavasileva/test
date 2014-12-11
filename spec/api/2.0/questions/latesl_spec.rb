require 'rails_helper'

describe :latest do
  let(:params) {{}}
  let(:setup_questions) {}
  let(:before_api_call) {}
  before { setup_questions }
  before { before_api_call }
  before { post "v/2.0/questions/latest", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

  context "With all required params" do
    let(:params) {{auth_token: auth_token, cursor: cursor, count: count}}
    let(:cursor) {0}
    let(:count) {10}

    context "With an unauthorized instance" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :unauthorized}

      it {expect(response.status).to eq 200}
      it {expect(json['error_code']).to eq 403}
      it {expect(json['error_message']).to match /Login required/}
    end

    context "With an authorized instance" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :authorized, user:user}

      context "When no user is associated with the instnace" do
        let(:user) {}

        it {expect(response.status).to eq 200}
        it {expect(json['error_code']).to eq 403}
        it {expect(json['error_message']).to match /Login required/}
      end

      context "When a user is associated with the instnace" do
        let(:user) {FactoryGirl.create :user}

        context "With one of each type of question" do
          before(:all) do
            @question_image = FactoryGirl.create :question_image
            @choice_image = FactoryGirl.create :choice_image
            @order_choice_image = FactoryGirl.create :order_choice_image
          end

          let(:question_image) {@question_image}
          let(:choice_image) {@choice_image}
          let(:order_choice_image) {@order_choice_image}
          let(:category1) {FactoryGirl.create :category, name:"Category 1"}
          let(:category2) {FactoryGirl.create :category, name:"Category 2"}

          let(:text_choice_question) {FactoryGirl.create :text_choice_question, category:category1, title:"Text Choice Title", description:"Text Choice Description", background_image:question_image, rotate:true, created_at:Date.today - 4.days}
          let(:text_choice1) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 1", rotate:true}
          let(:text_choice2) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 2", rotate:true}
          let(:text_choice3) {FactoryGirl.create :text_choice, question:text_choice_question, title:"Text Choice 3", rotate:false}

          let(:multiple_choice_question) {FactoryGirl.create :multiple_choice_question, category:category2, title:"Multiple Choice Title", description:"Multiple Choice Description", rotate:true, min_responses:1, max_responses:2, created_at:Date.today - 3.days}
          let(:multiple_choice1) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 1", background_image:choice_image, rotate:true, muex:true}
          let(:multiple_choice2) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 2", background_image:choice_image, rotate:true, muex:false}
          let(:multiple_choice3) {FactoryGirl.create :multiple_choice, question:multiple_choice_question, title:"Multiple Choice 3", background_image:choice_image, rotate:false, muex:true}

          let(:image_choice_question) {FactoryGirl.create :image_choice_question, category:category2, title:"Image Choice Title", description:"Image Choice Description", rotate:false, created_at:Date.today - 2.days}
          let(:image_choice1) {FactoryGirl.create :image_choice, question:image_choice_question, title:"Image Choice 1", background_image:choice_image, rotate:false}
          let(:image_choice2) {FactoryGirl.create :image_choice, question:image_choice_question, title:"Image Choice 2", background_image:choice_image, rotate:false}

          let(:order_question) {FactoryGirl.create :order_question, category:category1, title:"Order Title", description:"Order Description", rotate:true, created_at:Date.today - 1.day}
          let(:order_choice1) {FactoryGirl.create :order_choice, question:order_question, title:"Order Choice 1", background_image:order_choice_image, rotate:true}
          let(:order_choice2) {FactoryGirl.create :order_choice, question:order_question, title:"Order Choice 2", background_image:order_choice_image, rotate:true}
          let(:order_choice3) {FactoryGirl.create :order_choice, question:order_question, title:"Order Choice 3", background_image:order_choice_image, rotate:false}

          let(:text_question) {FactoryGirl.create :text_question, category:category1, title:"Text Title", description:"Text Description", background_image:question_image, text_type:"freeform", min_characters:1, max_characters:100, created_at:Date.today}

          let(:q1) { text_choice_question }
          let(:q2) { multiple_choice_question }
          let(:q3) { image_choice_question }
          let(:q4) { order_question }
          let(:q5) { text_question }

          let(:all_questions) { [q1, q2, q3, q4, q5] }

          let(:setup_questions) {
            all_questions

            text_choice1; text_choice2; text_choice3
            multiple_choice1; multiple_choice2; multiple_choice3
            image_choice1; image_choice2
            order_choice1; order_choice2; order_choice3
          }

          it {expect(json['cursor']).not_to be_nil}
          it {expect(json['questions']).not_to be_nil}
          it {expect(json['questions'].count).to eq 5}

          it {expect(response.status).to eq 201}
          it {expect(json['error_code']).to be_nil}
          it {expect(json['error_message']).to be_nil}

          describe "Question Output" do
            it {expect(json['questions'].count).to eq 5}

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

                expect(choices[0]['choice']['id']).to eq multiple_choice1.id
                expect(choices[0]['choice']['title']).to eq "Multiple Choice 1"
                expect(choices[0]['choice']['rotate']).to eq true
                expect(choices[0]['choice']['muex']).to eq true
                expect(choices[0]['choice']['image_url']).not_to be_nil

                expect(choices[1]['choice']['id']).to eq multiple_choice2.id
                expect(choices[1]['choice']['title']).to eq "Multiple Choice 2"
                expect(choices[1]['choice']['rotate']).to eq true
                expect(choices[1]['choice']['muex']).to eq false
                expect(choices[1]['choice']['image_url']).not_to be_nil

                expect(choices[2]['choice']['id']).to eq multiple_choice3.id
                expect(choices[2]['choice']['title']).to eq "Multiple Choice 3"
                expect(choices[2]['choice']['rotate']).to eq false
                expect(choices[2]['choice']['muex']).to eq true
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
                expect(q['rotate']).to eq false
                expect(q['category']['name']).to eq "Category 2"
                expect(q['comment_count']).to eq 0
                expect(q['response_count']).to eq 0
                expect(q['created_at']).to_not be_nil
                expect(q['image_url']).not_to be_nil


                choices = q['choices']

                expect(choices.count).to eq 2

                expect(choices[0]['choice']['id']).to eq image_choice1.id
                expect(choices[0]['choice']['title']).to eq "Image Choice 1"
                expect(choices[0]['choice']['rotate']).to eq false
                expect(choices[0]['choice']['image_url']).not_to be_nil

                expect(choices[1]['choice']['id']).to eq image_choice2.id
                expect(choices[1]['choice']['title']).to eq "Image Choice 2"
                expect(choices[1]['choice']['rotate']).to eq false
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

                expect(choices[0]['choice']['id']).to eq order_choice1.id
                expect(choices[0]['choice']['title']).to eq "Order Choice 1"
                expect(choices[0]['choice']['rotate']).to eq true
                expect(choices[0]['choice']['image_url']).not_to be_nil

                expect(choices[1]['choice']['id']).to eq order_choice2.id
                expect(choices[1]['choice']['title']).to eq "Order Choice 2"
                expect(choices[1]['choice']['rotate']).to eq true
                expect(choices[1]['choice']['image_url']).not_to be_nil

                expect(choices[2]['choice']['id']).to eq order_choice3.id
                expect(choices[2]['choice']['title']).to eq "Order Choice 3"
                expect(choices[2]['choice']['rotate']).to eq false
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

          context "When the user has answered the text choice question" do
            let(:text_choice_response) {FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1}
            let(:user) {text_choice_response.user}

            it {expect(json['questions'].count).to eq all_questions.count - 1}
            it {expect(json['questions'][3]['id']).to eq multiple_choice_question.id}
            it {expect(json['questions'][2]['id']).to eq image_choice_question.id}
          end

          context "When the text_choice_question has been responded to by another user" do
            context "With no comment" do
              let(:before_api_call) {FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1}

              it {expect(json['questions'].count).to eq all_questions.count}
              it {expect(json['questions'][4]['id']).to eq text_choice_question.id}
              it {expect(json['questions'][4]['comment_count']).to eq 0}
              it {expect(json['questions'][4]['response_count']).to eq 1}
            end

            context "With a comment" do
              let(:before_api_call) {
                response = FactoryGirl.create :text_choice_response, question:text_choice_question, choice:text_choice1
                response.create_comment user:response.user, body:"Some comment"
              }

              it {expect(json['questions'].count).to eq all_questions.count}
              it {expect(json['questions'][4]['id']).to eq text_choice_question.id}
              it {expect(json['questions'][4]['comment_count']).to eq 1}
              it {expect(json['questions'][4]['response_count']).to eq 1}
            end
          end

          describe "Cursor and count" do
            context "When the cursor is 0 and the count is 2" do
              let(:cursor) {0}
              let(:count) {2}

              it {expect(json['questions'].count).to eq 2}
              it {expect(json['questions'].map{|q| q["id"]}).to eq [q5.id, q4.id]}
              it {expect(json['cursor']).to eq q4.id}
            end

            context "When the cursor is the id of the 2nd newest question and count is 2" do
              let(:cursor) {q4.id}
              let(:count) {2}

              it {expect(json['questions'].count).to eq 2}
              it {expect(json['questions'].map{|q| q["id"]}).to eq [q3.id, q2.id]}
              it {expect(json['cursor']).to eq q2.id}

              context "When count is greater than the number of questions remaining" do
                let(:count) {200}

                it {expect(json['questions'].count).to eq 3}
                it {expect(json['questions'].map{|q| q["id"]}).to eq [q3.id, q2.id, q1.id]}
                it {expect(json['cursor']).to eq q1.id}
              end

              context "When the cursor is the last item in the list" do
                let(:cursor) {q1.id}
                let(:count) {2}

                it {expect(json['questions'].count).to eq 0}
                it {expect(json['questions']).to eq []}
                it {expect(json['cursor']).to eq 0}
              end
            end
          end
        end
      end
    end
  end
end
