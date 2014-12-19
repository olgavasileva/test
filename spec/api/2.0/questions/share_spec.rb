require 'rails_helper'

describe 'POST questions/share' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in, :can_push) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.user.auth_token,
    question_id: question.id
  } }
  let(:request) { -> { post 'v/2.0/questions/share', params } }

  it "increments question's share count" do
    2.times do
      expect {request.call}.to change {question.reload.share_count || 0}.by(1)
    end
  end
end
