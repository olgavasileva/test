require 'rails_helper'

describe 'POST /comments' do
  let(:instance) { FactoryGirl.create :instance, :logged_in }
  let(:question) { parent.commentable }
  let!(:parent) { FactoryGirl.create :text_question_comment }
  let(:params) { {
    auth_token: instance.user.auth_token,
    question_id: question.id,
    parent_id: parent.id,
    content: "tl;dr"
  } }
  let(:request) { -> { post 'v/2.0/comments', params } }
  let(:response_body) { JSON.parse(response.body) }

  it "creates a comment" do
    expect { request.call }.to change { Comment.count }.by(1)
  end

  it "responds with comment data" do
    request.call

    keys = %w[id user_id comment created_at email ask_count response_count
              comment_count comment_children]

    expect(response_body.keys).to match_array keys
  end
end
