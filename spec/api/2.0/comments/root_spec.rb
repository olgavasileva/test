require 'rails_helper'

describe :comments do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:q_response) { FactoryGirl.create(:text_response,
                                        comment: "This question is top-notch.",
                                        user_id: instance.user.id) }
  let(:params) { {
    instance_token: instance.uuid,
    auth_token: instance.auth_token,
    question_id: q_response.question.id
  } }
  let(:response_body) { JSON.parse(response.body) }

  before { post 'v/2.0/comments', params }

  it "responds with comments data" do
    keys = %w[id user_id comment created_at email ask_count response_count
              comment_count comment_children]

    expect(response_body).to be_instance_of Array
    expect(response_body.first.keys).to match_array keys
  end
end
