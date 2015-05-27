require 'rails_helper'

describe :asked do
  let(:count) { 5 }
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let!(:questions) { (1..count).map{|n| FactoryGirl.create(:question, user: instance.user, created_at: Time.now - (count - n).hours)} }
  let(:common_params) { {
    auth_token: instance.auth_token
  } }
  let(:other_params) {{ }}
  let(:params) { common_params.merge(other_params) }
  let(:response_body) { JSON.parse(response.body) }
  let(:response_question_ids) { response_body.map { |d| d['id'] } }

  before do
    post 'v/2.0/questions/asked', params
  end

  it "responds with data for all logged in user's questions" do
    expect(response_body.count).to eq count
  end

  it "responds with correct data fields" do
    response_body.each do |data|
      expect(data.keys).to match_array %w[id title created_at survey_id survey_uuid creator_id]
    end
  end

  context 'as part of a survey' do
    let(:survey) { FactoryGirl.create(:survey, :embeddable) }
    let!(:questions) do
      survey.questions.tap do |qs|
        qs.update_all(user_id: instance.user_id)
      end
    end

    it 'returns survey information' do
      json = response_body.first
      expect(json['survey_id']).to eq(survey.id)
      expect(json['survey_uuid']).to eq(survey.uuid)
    end
  end

  context 'with user_id' do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_params) {{ user_id: user.id }}
    let!(:questions) {(1..count).map{|n| FactoryGirl.create(:question, user: user, created_at: Time.now - n.hours)}}

    it "responds with data for all given user's questions" do
      expect(response_body.count).to eq count
    end

    context 'user has anonymous questions' do
      let!(:anonymous_question) { FactoryGirl.create :question, user: user, anonymous: true }

      it {expect(response_body.count).to eq count}
    end
  end

  context "with previous_last_id" do
    let(:other_params) {{ previous_last_id: questions[-2].id }}

    it "returns records after the one specified by previous_last_id" do
      expect(response_question_ids).to eq [questions[-1].id]
    end
  end

  context "with count" do
    let(:other_params) {{ count: 2 }}

    it "returns first n records specified by count" do
      expect(response_question_ids).to eq questions.first(2).map(&:id)
    end
  end

  context "with reverse" do
    let(:other_params) {{ reverse: true }}

    it "returns questions in reverse order" do
      expect(response_question_ids).to eq questions.map(&:id).reverse
    end
  end

  context 'with anonymous question' do
    let!(:anonymous_question) { FactoryGirl.create :question, anonymous: true, user: instance.user }
    before { post 'v/2.0/questions/asked', params }
    context 'as owner' do
      it {expect(response_question_ids).to include(anonymous_question.id)}
    end

    context 'as other user' do
      let(:another_instance) { FactoryGirl.create :instance, :logged_in }
      let(:params) {
        {auth_token: another_instance.auth_token, user_id: instance.user.id}
      }
      before { post 'v/2.0/questions/asked', params }
      it { expect(response_question_ids).not_to include(anonymous_question.id) }
    end

  end
end
