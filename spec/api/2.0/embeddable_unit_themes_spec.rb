require 'rails_helper'

describe 'GET /embeddable_unit_themes' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:user) { instance.user }
  let(:params) { {auth_token: instance.auth_token} }

  it 'creates theme' do
    theme_params = {
        title: 'title', main_color: 'blue', color1: 'green', color2: 'yellow'
    }
    post '/v/2.0/embeddable_unit_themes', theme_params.merge(params)

    expect(json['title']).to eq theme_params[:title]
  end

  it 'updates theme' do
    theme = user.embeddable_unit_themes.create title: 'title', main_color: 'blue', color1: 'green', color2: 'yellow'

    put '/v/2.0/embeddable_unit_themes', {title: 'asd', id: theme.id}.merge(params)

    expect(json['title']).to eq 'asd'
  end

  it 'deletes theme' do
    theme = user.embeddable_unit_themes.create title: 'title', main_color: 'blue', color1: 'green', color2: 'yellow'

    delete '/v/2.0/embeddable_unit_themes', {id: theme.id}.merge(params)

    themes = user.embeddable_unit_themes.reload

    expect(json.empty?).to be true

    expect(themes.length).to eq 0
  end

end