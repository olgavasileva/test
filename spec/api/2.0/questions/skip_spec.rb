require 'rails_helper'

describe 'PUT questions/skip' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
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
end
