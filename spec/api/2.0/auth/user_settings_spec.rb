require 'rails_helper'

describe :user_settings do

  let(:user) { FactoryGirl.create(:user) }
  let(:instance) { FactoryGirl.create(:instance, :logged_in, user: user) }

  let(:params) { {auth_token: instance.auth_token} }

  describe 'GET user/settings' do
    it 'has a 200 status' do
      get 'v/2.0/users/settings', params
      expect(response.status).to eq(200)
    end

    it 'renders the :user_settings' do
      get 'v/2.0/users/settings', params
      expect_user_json(user)
    end
  end

  describe 'PUT user/settings' do
    before { params.merge!(push_on_question_asked: 65) }

    it 'updates the user' do
      expect {
        put 'v/2.0/users/settings', params
      }.to change{user.reload.push_on_question_asked}
    end

    it 'has a 200 status' do
      put 'v/2.0/users/settings', params
      expect(response.status).to eq(200)
    end

    it 'renders the :user_settings' do
      put 'v/2.0/users/settings', params
      expect_user_json(user.reload)
    end
  end

  private

  def expect_user_json(u)
    expect(json).to eq({
      'push_on_question_answered' => user.push_on_question_answered,
      'push_on_question_asked' => user.push_on_question_asked
    })
  end
end
