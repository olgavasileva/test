require 'rails_helper'

describe 'POST questions/start' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in, :can_push) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.auth_token,
    question_id: question.id
  } }
  let(:request) { -> { post 'v/2.0/questions/start', params } }

  it "increments question's start count" do
    2.times do
      expect {request.call}.to change {question.reload.start_count || 0}.by(1)
    end
  end
end
