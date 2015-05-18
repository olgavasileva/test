require 'rails_helper'

RSpec.describe TwoCents::Auth, 'DELETE /social' do

  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:user) { instance.user }
  let!(:auth) { FactoryGirl.create(:authentication, user: user) }

  subject do
    params = {auth_token: instance.auth_token, provider_id: auth.id}
    delete 'v/2.0/users/social', params
  end

  context 'with valid attributes' do
    it 'returns a 204 No Content' do
      subject
      expect(response.status).to eq(204)
    end

    it 'deletes the the Authentication record' do
      expect{ subject }.to change{user.reload.authentications.count}.by(-1)
    end
  end
end
