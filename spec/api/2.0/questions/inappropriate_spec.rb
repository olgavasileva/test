require 'rails_helper'

describe :inappropriate do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:question) { FactoryGirl.create(:question) }
  let(:reason) { "I was offended." }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:request) { -> { post 'v/2.0/questions/inappropriate', params } }
  let(:response_body) { JSON.parse(response.body) }

  shared_examples :fail do
    it "responds with error data" do
      expect(response_body.keys).to match_array %w[error_code error_message]
    end
  end

  shared_examples :success do
    it "responds with a 201" do
      expect(response.status).to eq 201
    end

    it "responds with no data" do
      expect(response_body.keys).to match_array []
    end
  end

  context "without question_id" do
    let(:params) { common_params.merge(reason: reason) }
    before { request.call }

    include_examples :fail
  end

  context "without reason" do
    let(:params) { common_params.merge(question_id: question.id) }
    before { request.call }

    include_examples :fail
  end

  context "with valid question_id and reason" do
    let(:params) {
      common_params.merge(question_id: question.id, reason: reason) }
    before { request.call }

    include_examples :success
  end

  context "with valid reason, invalid question_id" do
    let(:params) {
      common_params.merge(question_id: -1, reason: reason) }
    before { request.call }

    include_examples :fail
  end
end
