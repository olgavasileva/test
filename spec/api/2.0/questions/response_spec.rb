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
    it {expect(json).to_not be_nil}
    it {expect(json['error_code']).to eq 400}
    it {expect(json['error_message']).to match /.+ is missing/}
  end

  context "With all required params" do
    let(:other_params) { Hash.new }
    let(:params) { {auth_token:auth_token, question_id:question_id}.merge(other_params) }
    let(:question_id) {0}

    context "With an invalid auth token" do
      let(:auth_token) {"INVALID"}

      it {expect(response.status).to eq 200}
      it {expect(json['error_code']).to eq 402}
      it {expect(json['error_message']).to match /Invalid auth token/}
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
          summary = json['summary']

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
          expect(summary.keys).to include('demographic_required')
        end

        context "When user.demographics.quantcast is empty" do
          it {expect(json['summary'].keys).to include('demographic_required')}
          it {expect(json['summary']['demographic_required']).to eq true}
        end

        context "When user.demographics.quantcast.first was updated 1 month ago" do
          let (:before_api_call) {FactoryGirl.create(:demographic, :quantcast, respondent: user, updated_at: Date.current - 1.month)}
          it {expect(json['summary']['demographic_required']).to eq false}
        end

        context "When user.demographic was updated 1 month and 1 day ago" do
          let (:before_api_call) {FactoryGirl.create(:demographic, :quantcast, respondent: user, updated_at: Date.current - 1.month - 1.day)}
          it {expect(json['summary']['demographic_required']).to eq true}
        end
      end

      describe ':orginal_referrer' do
        let(:question) {FactoryGirl.create :text_question}
        let(:question_id) {question.id}
        let(:other_params) { {text: 'yes', original_referrer: 'http://facebook.com/path'} }

        it 'stores the referrer' do
          referrer = 'http://facebook.com/path'
          expect(question.responses.last.original_referrer).to eq(referrer)
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

        context "When the source parameter is set" do
          let(:other_params) { { source: source, choice_ids: [FactoryGirl.create(:order_choice, question: question).id] } }

          context "When source is web" do
            let(:source) {'web'}
            it {expect(Response.last.source).to eq 'web'}
          end

          context "When source is embeddable" do
            let(:source) {'embeddable'}
            it {expect(Response.last.source).to eq 'embeddable'}
          end

          context "When source is ios" do
            let(:source) {'ios'}
            it {expect(Response.last.source).to eq 'ios'}
          end

          context "When source is android" do
            let(:source) {'android'}
            it {expect(Response.last.source).to eq 'android'}
          end

          context "When source is invalid" do
            let(:source) {'invalid'}
            it {expect(response.status).to eq 200}
            it {expect(json['error_message']).to eq 'source does not have a valid value'}
          end
        end
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
end
