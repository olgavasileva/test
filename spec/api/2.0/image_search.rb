require 'rails_helper'

describe :image_search do

  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) {
    {auth_token: instance.auth_token, search: 'some search query'}
  }
  let(:search_result) {
    [{
      Image: [
        {MediaUrl: 'first', Thumbnail: {MediaUrl: 'first/thumbnail'}},
        {MediaUrl: 'second', Thumbnail: {MediaUrl: 'second/thumbnail'}},
      ]
    }]
  }
  before do
    allow_any_instance_of(Bing).to receive(:search).and_return(search_result)
  end

  it 'responds with image URLs' do
    get '/v/2.0/image_search', params
    json = JSON.parse(response.body)
    expect(json.length).to eq 2

    expect(json[0]).to eq({
      'media_url' => 'first',
      'thumbnail' => 'first/thumbnail'
    })

    expect(json[1]).to eq({
      'media_url' => 'second',
      'thumbnail' => 'second/thumbnail',
    })
  end
end
