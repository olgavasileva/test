require 'rails_helper'

describe 'PUT questions/skip' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in, :can_push) }
  let(:feed_item) { FactoryGirl.create :feed_item, user: instance.user }
  let(:question) { feed_item.question }
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
    expect(instance.user.question_action_skips.where(question_id: question.id)).to be_present
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
