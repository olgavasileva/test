require 'rails_helper'

RSpec.describe TwoCents::Questions do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:token) { instance.auth_token }

  before(:all) do
    @questions = FactoryGirl.create_list(:text_choice_question, 2, {
      tag_list: ['test']
    })
  end

  after(:all) { @questions.map(&:destroy!) }

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
