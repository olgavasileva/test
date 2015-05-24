require 'rails_helper'

describe :answered do
  let(:count) { 2 }
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let!(:questions) { FactoryGirl.create_list(:question, count) }
  let!(:responses) { questions.map { |q| FactoryGirl.create(:text_response, question: q, user: instance.user) } }
  let(:ordered_question_ids) { responses.map(&:question_id) }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:other_params) {{ }}
  let(:params) { common_params.merge(other_params) }
  let(:request) { -> { post 'v/2.0/questions/answered', params } }
  let(:response_body) { JSON.parse(response.body) }
  let(:response_question_ids) { response_body.map { |d| d['id'] } }

  before { post 'v/2.0/questions/answered', params }

  it "responds with data for all logged in user's answered questions" do
    expect(response_body.count).to eq count
  end

  it "responds with correct data fields" do
    keys = %w[id title responded_at]

    response_body.each do |data|
      expect(data.keys).to match_array keys
    end
  end

  context 'with user_id' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_params) {{ user_id: user.id }}
    let!(:responses) { questions.map { |q| FactoryGirl.create(:text_response, question: q, user: user, anonymous: false) } }

    it "responds with data for all given user's answered questions" do
      expect(response_body.count).to eq count
    end

    context 'user have anonymous responses' do
      let(:anonymous_response) { FactoryGirl.create :text_response, user: user, anonymous: true }

      it { expect(response_body.count).to eq count }
    end
  end

  context "with previous_last_id" do
    let(:other_params) {{ previous_last_id: ordered_question_ids[-2] }}

    it "returns records after the one specified by previous_last_id" do
      expect(response_question_ids).to eq [ordered_question_ids[-1]]
    end
  end

  context "with count" do
    let(:count) { 3 }
    let(:other_params) {{ count: 2 }}

    it "returns first n records specified by count" do
      expect(response_question_ids).to eq ordered_question_ids.first(2)
    end
  end

  context "with reverse" do
    let(:other_params) {{ reverse: true }}

    it "returns questions in reverse order" do
      expect(response_question_ids).to eq ordered_question_ids.reverse
    end
  end

end
