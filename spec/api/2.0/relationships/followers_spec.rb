require 'rails_helper'

describe 'relationships/followers' do
  let(:count) { 2 }
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:request) { -> { get 'v/2.0/relationships/followers', params } }
  let(:response_body) { JSON.parse(response.body) }

  before do
    instance.user.followers = FactoryGirl.create_list(:user, count)

    instance.user.groups = FactoryGirl.create_list(:group, 2)
    instance.user.followers.each_with_index do |follower, i|
      instance.user.groups[i % 2].member_users << follower
    end
  end

  shared_examples :correct_fields do
    it "responds with correct data fields" do
      response_body.each do |data|
        expect(data.keys).to match_array %w[id username email name group_ids]
      end
    end

    it "responds with group_ids representing user's groups that follower is in" do
      response_body.each do |data|
        follower = User.find(data['id'])
        leader_follower_groups = instance.user.groups.select { |g|
          g.member_users.include? follower }

        expect(data['group_ids']).to match_array leader_follower_groups.map(&:id)
      end
    end
  end

  context "without user_id" do
    let(:params) { common_params }

    before { request.call }

    it "responds with data for all logged in user's followers" do
      expect(response_body.count).to eq count
    end

    include_examples :correct_fields
  end

  context "with user_id" do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) { common_params.merge(user_id: user.id) }

    before do
      user.followers = FactoryGirl.create_list(:user, count)

      request.call
    end

    it "responds with data for all given user's followers" do
      expect(response_body.count).to eq count
    end

    include_examples :correct_fields
  end

  context "with page" do
    let(:count) { 15 }
    let(:params) { common_params.merge(page: 1) }

    before { request.call }

    it "responds with data for up to 15 followers" do
      expect(response_body.count).to eq 15
    end

    include_examples :correct_fields

    context "with per_page" do
      let(:per_page) { 1 }
      let(:params) { common_params.merge(page: 1, per_page: per_page) }

      it "responds with data for up to `per_page` followers" do
        expect(response_body.count).to eq per_page
      end
    end
  end
end
