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

  def expect_failure code, error_message_regex
    expect(response_body.keys).to match_array %w[error_code error_message]
    expect(response_body['error_code']).to eq code
    expect(response_body['error_message']).to match error_message_regex
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

    it {expect_failure 400, /question_id is missing/}
  end

  context "without reason" do
    let(:params) { common_params.merge(question_id: question.id) }
    before { request.call }

    it {expect_failure 400, /reason is missing/}
  end

  context "with valid reason, invalid question_id" do
    let(:params) { common_params.merge(question_id: -1, reason: reason) }
    before { request.call }

    it {expect_failure 401, /Couldn't find Question with 'id'=-1/}
  end

  context "with valid question_id and blank reason" do
    let(:params) { common_params.merge(question_id: question.id, reason: "") }
    before { request.call }

    it {expect_failure 499, /Reason can't be blank/}
  end

  context "with valid question_id and reason" do
    let(:params) { common_params.merge(question_id: question.id, reason: reason) }
    before { request.call }

    include_examples :success
  end
end
