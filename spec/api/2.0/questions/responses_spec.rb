require 'rails_helper'

describe 'questions/responses' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.user.auth_token
  } }
  let(:request) { -> { get 'v/2.0/questions/responses', params } }
  let(:response_body) { JSON.parse(response.body) }

  before { request.call }

  shared_examples :fail do
    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end

  shared_examples :success do
    it "responds with response data" do
      expect(response_body.first.keys).to match_array %w[id user_id text]
    end
  end

  context "without question_id" do
    let(:params) { common_params }

    include_examples :fail
  end

  context "with question_id" do
    let(:question) { FactoryGirl.create(:text_question) }
    let(:responses) { FactoryGirl.create_list(:text_response, 16) }
    let(:params) { common_params.merge(question_id: question.id) }

    before do
      question.responses = responses
      request.call
    end

    include_examples :success

    it "responds with data for all question's responses" do
      expect(response_body.count).to eq responses.count
    end

    context "with question not public" do
      let(:question) { FactoryGirl.create(:text_question, kind: 'targeted') }

      include_examples :fail

      context "with question belonging to user" do
        let(:question) { FactoryGirl.create(:text_question,
                                            kind: 'targeted',
                                            user: instance.user) }

        include_examples :success
      end
    end

    context "with page param" do
      let(:params) { common_params.merge(question_id: question.id, page: 1) }

      include_examples :success

      it "responds with up to 15 of question's responses" do
        expect(response_body.count).to eq 15
      end

      context "with per_page param" do
        let(:per_page) { 8 }
        let(:params) { common_params.merge(question_id: question.id,
                                           page: 1, per_page: per_page) }

        it "responds with up to per_page of question's responses" do
          expect(response_body.count).to eq per_page
        end
      end
    end
  end
end
