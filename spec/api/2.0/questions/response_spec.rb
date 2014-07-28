require 'rails_helper'

describe :feed do
  let(:params) {{}}
  let(:before_api_call) {}
  before { before_api_call }
  before { post "v/2.0/questions/response", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}

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

        describe "TextQuestion response" do
          let(:question) {FactoryGirl.create :text_question}
          let(:question_id) {question.id}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('response_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('view_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('comment_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('share_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('skip_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('published_at')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('sponsor')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_id')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_name')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('anonymous')}
        end

        describe "TextChoiceQuestion response" do
          let(:question) {FactoryGirl.create :text_choice_question}
          let(:question_id) {question.id}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('response_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('view_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('comment_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('share_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('skip_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('published_at')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('sponsor')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_id')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_name')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('anonymous')}
        end

        describe "ImageChoiceQuestion response" do
          let(:question) {FactoryGirl.create :image_choice_question}
          let(:question_id) {question.id}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('response_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('view_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('comment_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('share_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('skip_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('published_at')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('sponsor')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_id')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_name')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('anonymous')}
        end

        describe "MultipleChoiceQuestion response" do
          let(:question) {FactoryGirl.create :multiple_choice_question}
          let(:question_id) {question.id}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('response_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('view_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('comment_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('share_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('skip_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('published_at')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('sponsor')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_id')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_name')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('anonymous')}
        end

        describe "OrderQuestion response" do
          let(:question) {FactoryGirl.create :order_question}
          let(:question_id) {question.id}

          it {expect(response.status).to eq 201}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('response_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('view_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('comment_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('share_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('skip_count')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('published_at')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('sponsor')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_id')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('creator_name')}
          it {expect(JSON.parse(response.body)['summary'].keys).to include('anonymous')}
        end
      end
    end
  end
end
