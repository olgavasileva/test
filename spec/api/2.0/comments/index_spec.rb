require 'rails_helper'

describe 'GET /comments' do
  let(:instance) { FactoryGirl.create :instance, :authorized, :logged_in }
  let(:answer) {
    response_comment = FactoryGirl.create :text_response_comment
    response_comment.commentable
  }
  let(:question) { answer.question }

  let(:params) { {
    auth_token: instance.auth_token,
    question_id: question.id
  } }
  let(:response_body) { JSON.parse(response.body) }

  before { get 'v/2.0/comments', params }

  it "responds with comments data" do
    keys = %w[id user_id comment created_at email ask_count response_count
              comment_count comment_children]

    expect(response_body).to be_instance_of Array
    expect(response_body.count).to eq 1
    expect(response_body.first.keys).to match_array keys
  end
end
