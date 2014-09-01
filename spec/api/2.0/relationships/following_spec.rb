require 'rails_helper'

describe 'relationships/following' do
  let(:count) { 20 }
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:request) { -> { get 'v/2.0/relationships/following', params } }
  let(:response_body) { JSON.parse(response.body) }

  before do
    instance.user.leaders = FactoryGirl.create_list(:user, count)
  end

  shared_examples :correct_fields do
    it "responds with correct data fields" do
      response_body.each do |data|
        expect(data.keys).to match_array %w[id username email name group_ids]
      end
    end
  end

  context "without user_id" do
    let(:params) { common_params }

    before { request.call }

    it "responds with data for all logged in user's leaders" do
      expect(response_body.count).to eq count
    end

    include_examples :correct_fields
  end

  context "with user_id" do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) { common_params.merge(user_id: user.id) }

    before do
      user.leaders = FactoryGirl.create_list(:user, count)

      request.call
    end

    it "responds with data for all given user's leaders" do
      expect(response_body.count).to eq count
    end

    include_examples :correct_fields
  end

  context "with page" do
    let(:params) { common_params.merge(page: 1) }

    before { request.call }

    it "responds with data for up to 15 leaders" do
      expect(response_body.count).to eq 15
    end

    include_examples :correct_fields

    context "with per_page" do
      let(:per_page) { 5 }
      let(:params) { common_params.merge(page: 1, per_page: per_page) }

      it "responds with data for up to `per_page` leaders" do
        expect(response_body.count).to eq per_page
      end
    end
  end
end
