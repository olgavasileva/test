require 'rails_helper'

describe 'comments/user' do
  let(:count) { 3 }
  let(:instance) {FactoryGirl.create :instance, :logged_in}
  let(:user) { instance.user }
  let(:comments) { FactoryGirl.create_list(:text_response_comment, count, user: user) }
  let(:ordered_question_ids) { comments.map(&:commentable).map(&:question_id) }
  let(:common_params) { { auth_token: instance.auth_token } }
  let(:other_params) {{ }}
  let(:params) { common_params.merge(other_params) }
  let(:response_question_ids) { json.map { |d| d['question_id'] } }

  before { comments }
  before { post 'v/2.0/comments/user', params }

  it "responds with correct data fields" do
    json.each do |data|
      fields = %w[question_id question_title last_commented_at]
      expect(data.keys).to match_array fields
    end
  end

  it "has last commented at for each question" do
    json.each do |data|
      expect(data['last_commented_at']).to_not be_nil
    end
  end

  it "responds with data for all logged in user's comments" do
    expect(response_question_ids).to eq ordered_question_ids
  end

  context "with reverse" do
    let(:other_params) {{ reverse: true }}

    it "returns questions in reverse order" do
      expect(response_question_ids).to eq ordered_question_ids.reverse
    end
  end

  context "with user_id" do
    let(:user) { FactoryGirl.create(:user) }
    let(:comments) { FactoryGirl.create_list(:text_response_comment, count, user: user) }
    let(:other_params) {{ user_id: user.id }}

    it "responds with data for all given user's comments" do
      expect(response_question_ids).to eq ordered_question_ids
    end
  end

  context "with previous_last_id" do
    let(:other_params) {{ previous_last_id: ordered_question_ids[-2] }}

    it "returns records after the one specified by previous_last_id" do
      expect(response_question_ids).to eq [ordered_question_ids[-1]]
    end
  end

  context "with count" do
    let(:other_params) {{ count: 2 }}

    it "returns first n records specified by count" do
      expect(response_question_ids).to eq ordered_question_ids.first(2)
    end
  end
end
