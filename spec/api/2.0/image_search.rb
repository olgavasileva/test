require 'rails_helper'

describe :image_search do

  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) {
    {auth_token: instance.auth_token, search: 'some search query'}
  }
  let(:search_result) {
    [{:Image => [{:MediaUrl => 'some url'}, {:MediaUrl => 'another url'}]}]
  }
  before do
    allow_any_instance_of(Bing).to receive(:search).and_return(search_result)
  end

  it 'respond with image URLs' do
    get '/v/2.0/image_search', params
    expect(JSON.parse(response.body).length).to eq 2
  end
end