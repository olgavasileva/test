require 'rails_helper'

RSpec.describe TwoCents::Trending, '/trending/tags' do
  before(:all) do
    @auth = FactoryGirl.create(:instance, :logged_in)
    FactoryGirl.create(:question, user: @auth.user, tag_list: ['lol'])
    FactoryGirl.create(:question, user: @auth.user, tag_list: ['lol', 'pepper'])
    FactoryGirl.create(:question, user: @auth.user, tag_list: ['pepper'])
    q = FactoryGirl.create(:question, user: @auth.user, tag_list: ['lol', 'food'])

    ActsAsTaggableOn::Tagging.where(taggable: q).update_all({
      created_at: 2.days.ago
    })
  end

  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:auth) { @auth }

  describe 'GET /trending/tags' do
    let(:params) { {auth_token: auth.auth_token} }
    subject { get "v/2.0/trending/tags", params }

    it 'returns the correct tags' do
      subject
      expect(json).to eq({
        'tags' => [
          {"tag" => "lol", "count" => 3},
          {"tag" => "pepper", "count" => 2},
          {"tag" => "food", "count" => 1}
        ]
      })
    end

    context 'given a per_page param' do
      before { params.merge!(per_page: 2) }

      it 'returns the correct number of tags' do
        subject
        expect(json['tags'].length).to eq(2)
      end
    end

    context 'given a page param' do
      before { params.merge!(page: 2, per_page: 1) }

      it 'returns the correct number of tags' do
        subject
        expect(json['tags']).to eq([{'tag' => "pepper", "count" => 2}])
      end
    end

    context 'given a days params' do
      before { params.merge!(days: 1) }

      it 'returns the correct tags' do
        subject
        expect(json['tags']).to eq([
          {'tag' => "lol", "count" => 2},
          {'tag' => "pepper", "count" => 2}
        ])
      end
    end
  end
end
