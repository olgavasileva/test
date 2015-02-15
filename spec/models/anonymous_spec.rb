require 'rails_helper'

RSpec.describe Anonymous do


  describe '#promote!' do
    it 'converts the record to a User' do
      anon = FactoryGirl.create(:anonymous)
      expect(anon).to receive(:update!).with(type: 'User').and_call_original
      user = anon.promote!(name: 'Test User')
      expect(user).to be_a(User)
    end

    it 'updates the record correctly' do
      anon = FactoryGirl.create(:anonymous)
      user = anon.promote!(name: 'Test User')
      expect(user.name).to eq('Test User')
    end
  end
end
