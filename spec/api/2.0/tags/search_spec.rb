require 'rails_helper'

RSpec.describe TwoCents::Tags do
  let(:instance) { FactoryGirl.create(:instance, :logged_in, :can_push) }
  let(:token) { instance.auth_token }

  before(:all) do
    @tags = (1..20).to_a.map do |n|
      ActsAsTaggableOn::Tag.create!(name: "tag%02d" % n )
    end
  end

  after(:all) { ActsAsTaggableOn::Tag.delete_all }

  describe 'GET #search' do
    it 'returns an array of tags ordered by name' do
      get 'v/2.0/tags/search', auth_token: token, search_string: 'tag', max_tags: 5
      expect(json).to eq(%w{tag01 tag02 tag03 tag04 tag05})
    end

    it 'returns a default :max_tags of 20' do
      get 'v/2.0/tags/search', auth_token: token, search_string: 'tag'
      expect(json.length).to eq(20)
    end

    it 'returns only the requested :max_tags' do
      get 'v/2.0/tags/search', auth_token: token, search_string: 'tag', max_tags: 10
      expect(json.length).to eq(10)
    end
  end
end
