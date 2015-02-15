require 'rails_helper'

RSpec.describe Instance do


  describe '#refresh_auth_token' do
    it 'updates the :auth_token attribute' do
      inst = Instance.new
      expect{inst.refresh_auth_token}.to change(inst, :auth_token)
    end

    it 'ensures the token starts with an A' do
      inst = Instance.new
      inst.refresh_auth_token
      expect(inst.auth_token).to match(/^A/)
    end
  end
end
