require 'rails_helper'

describe 'comments/user' do
  let(:count) { 3 }
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:request) { -> { post 'v/2.0/comments/user', params } }
  let(:response_body) { JSON.parse(response.body) }

  before { FactoryGirl.create_list(:text_response, count,
                                   user: instance.user,
                                   comment: "first!") }

  shared_examples :correct_fields do
    it "responds with correct data fields" do
      response_body.each do |data|
        expect(data.keys).to match_array %w[comment question_id]
      end
    end
  end

  context "without user_id" do
    let(:params) { common_params }

    before { request.call }

    it "responds with data for all logged in user's comments" do
      expect(response_body.count).to eq count
    end

    include_examples :correct_fields
  end

  context "with user_id" do
    let(:user) { FactoryGirl.create(:user) }
    let(:params) { common_params.merge(user_id: user.id) }

    before { FactoryGirl.create_list(:text_response, count,
                                     user: user,
                                     comment: "first!") }
    before { request.call }

    it "responds with data for all given user's comments" do
      expect(response_body.count).to eq count
    end

    include_examples :correct_fields
  end

  context "with page" do
    let(:count) { 20 }
    let(:params) { common_params.merge(page: 1) }

    before { request.call }

    it "responds with data for up to 15 comments" do
      expect(response_body.count).to eq 15
    end

    include_examples :correct_fields

    context "with per_page" do
      let(:count) { 7 }
      let(:per_page) { 5 }
      let(:params) { common_params.merge(page: 1, per_page: per_page) }

      it "responds with data for up to `per_page` comments" do
        expect(response_body.count).to eq per_page
      end
    end
  end
end
