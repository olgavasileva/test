require 'rails_helper'

RSpec.describe TwoCents::Questions do
  before(:all) do
    @instance = FactoryGirl.create(:instance, :logged_in)
    @questions = FactoryGirl.create_list(:text_choice_question, 2, {
      tag_list: ['test'],
      user: @instance.user
    })

    @questions.last.update_column(:created_at, 1.day.ago)
  end

  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:instance) { @instance }
  let(:token) { instance.auth_token }

  describe 'GET #tagged' do
    it 'returns the questions matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'test'
      expect(json.length).to eq(2)
    end

    it 'allows for mixed case queries' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'TesT'
      expect(json.length).to eq(2)
    end

    it 'returns :per_page number of questions matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'test', per_page: 1
      expect(json.length).to eq(1)
    end

    it 'returns :page number for the questions matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'test', per_page: 1, page: 2
      expect(json.first['question']['id']).to eq(@questions.last.id)
    end

    it 'does not return questions not matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'other'
      expect(json.length).to eq(0)
    end
  end
end
