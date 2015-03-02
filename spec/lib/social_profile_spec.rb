require 'rails_helper'

RSpec.describe SocialProfile do

  describe '.build' do
    it 'builds the correct adapter' do
      adapter = SocialProfile.build('facebook', 'some_token', 'some_secret')
      expect(adapter).to be_a(SocialProfile::FacebookAdapter)
      expect(adapter.token).to eq('some_token')
      expect(adapter.secret).to eq('some_secret')
    end

    it 'builds a BaseAdpater when given an invalid adapter' do
      adapter = SocialProfile.build('invalid', 'some_token', 'some_secret')
      expect(adapter).to be_a(SocialProfile::BaseAdapter)
    end
  end
end
