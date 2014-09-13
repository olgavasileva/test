require 'rails_helper'

describe 'questions/view' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.auth_token,
    question_id: question.id
  } }
  let(:request) { -> { post 'v/2.0/questions/view', params } }

  it "increments question's view count" do
    2.times do
      expect {request.call}.to change {question.reload.view_count || 0}.by(1)
    end
  end
end