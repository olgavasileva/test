require 'rails_helper'

describe 'relationships/followable' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:users) { FactoryGirl.create_list(:user, 10) }
  let!(:following) { instance.user.leaders = users.sample(5) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:request) { -> { get 'v/2.0/relationships/followable', params } }
  let(:response_body) { JSON.parse(response.body) }
  let(:response_ids) { response_body.map { |h| h['id'] } }

  shared_examples :common do
    it "returns data with expected fields" do
      expected_keys = %w[id username email name is_following]
      expect(response_body.first.keys).to eq expected_keys
    end

    it "returns data with correct `is_following`" do
      response_body.each do |datum|
        is_following = instance.user.leaders.include? User.find(datum['id'])

        expect(datum['is_following']).to eq is_following
      end
    end

    it "returns following users before other users" do
      following_ids = following.map(&:id)

      data_first_other_idx = response_body.find_index do |datum|
        !following_ids.include? datum['id']
      end

      response_body[0...data_first_other_idx].each do |datum|
        expect(following_ids).to include datum['id']
      end

      response_body[data_first_other_idx..-1].each do |datum|
        expect(following_ids).to_not include datum['id']
      end
    end
  end

  context "without search_text" do
    let(:params) { common_params }

    before { request.call }

    it "returns all users" do
      expect(response_ids).to match_array User.all.map(&:id)
      expect(response_body.count).to eq User.count
    end

    include_examples :common
  end

  context "with search_text" do
    let(:search_text) { '0' }
    let(:params) { common_params.merge(search_text: search_text) }

    before { request.call }

    it "returns matching users" do
      search_users = User.search(q: search_text).result

      expect(response_ids).to match_array search_users.map(&:id)
      expect(response_body.count).to eq search_users.count
    end

    include_examples :common
  end
end
