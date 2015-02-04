require 'rails_helper'

describe :response do
  let(:before_api_call) {}
  let(:request) { -> { post "v/2.0/questions/response", Hash[params].to_json,{"CONTENT_TYPE" => "application/json"}}}
  before { allow_any_instance_of(TextResponse).to receive(:spam?).and_return false }
  before { allow_any_instance_of(Comment).to receive(:spam?).and_return false }
  before do
    before_api_call
    request.call
  end

  context "Without the required params" do
    let(:params) {{}}

    it {expect(response.status).to eq 200}
    it {expect(JSON.parse(response.body)).to_not be_nil}
    it {expect(JSON.parse(response.body)['error_code']).to eq 400}
    it {expect(JSON.parse(response.body)['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:other_params) { Hash.new }
    let(:params) { {auth_token:auth_token, question_id:question_id}.merge(other_params) }
    let(:question_id) {0}

    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(JSON.parse(response.body)['error_code']).to eq 402}
      it {expect(JSON.parse(response.body)['error_message']).to match /Invalid auth token/}
    end

    context "With a logged in user" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :logged_in}
      let(:user) {instance.user}

      shared_examples :success do
        it {expect(response.status).to eq 201}

        it "creates a response record" do
          expect {request.call}.to change {Response.count}.by(1)
        end

        it "should return summary fields" do
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

      describe "TextQuestion response" do
        let(:question) {FactoryGirl.create :text_question}
        let(:question_id) {question.id}
        let(:other_params) { { text: 'yes' } }

        include_examples :success
      end

      describe "TextChoiceQuestion response" do
        let(:question) {FactoryGirl.create :text_choice_question}
        let(:question_id) {question.id}
        let(:other_params) { { choice_id: FactoryGirl.create(:text_choice, question: question).id } }

        include_examples :success
      end

      describe "ImageChoiceQuestion response" do
        let(:question) {FactoryGirl.create :image_choice_question}
        let(:question_id) {question.id}
        let(:other_params) { { choice_id: FactoryGirl.create(:image_choice, question: question).id } }

        include_examples :success
      end

      describe "MultipleChoiceQuestion response" do
        let(:question) {FactoryGirl.create :multiple_choice_question}
        let(:question_id) {question.id}
        let(:other_params) { { choice_id: FactoryGirl.create(:multiple_choice, question: question).id } }

        include_examples :success
      end

      describe "OrderQuestion response" do
        let(:question) {FactoryGirl.create :order_question}
        let(:question_id) {question.id}
        let(:other_params) { { choice_ids: [FactoryGirl.create(:order_choice, question: question).id] } }

        include_examples :success
      end
    end
  end

  describe 'check response for spam' do
    let(:instance) {FactoryGirl.create :instance, :logged_in}
    let(:auth_token) { instance.auth_token }
    let(:question) { FactoryGirl.create :text_question }
    let(:params) { {auth_token: auth_token,
                    question_id: question.id, text: 'some text with a spam message'} }
    it { expect(TextResponse.count).not_to eq 0 }

    context 'text has spam message' do
      before { allow_any_instance_of(TextResponse).to receive(:spam?).and_return true }
      before { @count = TextResponse.count }
      before { request.call }
      it { expect(TextResponse.count).to eq @count }
    end
  end

  describe 'Demographics' do
    let(:instance) {FactoryGirl.create :instance, :logged_in}
    let(:auth_token) { instance.auth_token }
    let(:question) { FactoryGirl.create :text_question }
    let(:params) { { auth_token: auth_token,
                     question_id: question.id,
                     text: 'some text',
                     demographic_gender: 'male',
                     demographic_age_range: "35-44",
                     demographic_household_income: "0-50k",
                     demographic_children: "true",
                     demographic_ethnicity: "caucasian",
                     demographic_education_level: "college",
                     demographic_political_affiliation: "independent",
                     demographic_political_engagement: "active"
                  } }

    it {expect(response.status).to eq 201}
    it {expect(JSON.parse(response.body)['error_message']).to be_nil}
    it {expect(question.reload.responses.last.demographic).to be_present}

    it {expect(question.reload.responses.last.demographic.gender).to eq 'male'}
    it {expect(question.reload.responses.last.demographic.age_range).to eq "35-44"}
    it {expect(question.reload.responses.last.demographic.household_income).to eq "0-50k"}
    it {expect(question.reload.responses.last.demographic.children).to eq "true"}
    it {expect(question.reload.responses.last.demographic.ethnicity).to eq "caucasian"}
    it {expect(question.reload.responses.last.demographic.education_level).to eq "college"}
    it {expect(question.reload.responses.last.demographic.political_affiliation).to eq "independent"}
    it {expect(question.reload.responses.last.demographic.political_engagement).to eq "active"}
  end
end
