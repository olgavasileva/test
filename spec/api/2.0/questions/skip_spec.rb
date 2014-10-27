require 'rails_helper'

describe 'PUT questions/skip' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in, :can_push) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.auth_token,
    question_id: question.id
  } }
  let(:response_body) { JSON.parse(response.body) }
  before { put 'v/2.0/questions/skip', params }

  it "responds with blank data" do
    expect(response_body).to eq Hash.new
  end

  it "skips the question" do
    skip = SkippedItem
      .where(user_id: instance.user.id, question_id: question.id).first

    expect(skip).to_not be_nil
  end

  context "with invalid question ID" do
    let(:params) { {
      auth_token: instance.auth_token,
      question_id: -1
    } }

    it "responds with error data" do
      expect(response_body.keys).to eq %w[error_code error_message]
    end
  end
end
