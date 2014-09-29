require 'rails_helper'

describe 'GET questions/question' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.auth_token,
    question_id: question.id
  } }
  let(:response_body) { JSON.parse(response.body) }
  before { get 'v/2.0/questions/question', params }

  it "returns all question data" do
    keys = %w[id type title description response_count comment_count
      creator_id creator_name choices category view_count share_count
      skip_count published_at sponsor anonymous user_answered]

    expect(response_body.keys).to match_array keys
  end
end
