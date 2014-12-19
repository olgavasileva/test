require 'rails_helper'

describe 'DELETE /questions' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:params) { {
    auth_token: instance.user.auth_token,
    id: question.id
  } }

  before { delete 'v/2.0/questions', params }

  context "When the question belogs to the user" do
    let(:question) { FactoryGirl.create :question, user: instance.user }

    it "suspends the question" do
      expect(Question.find_by_id(question.id).state).to eq "suspended"
    end

    it "responds with blank data" do
      expect(json).to eq Hash.new
    end
  end

  context "When the question belongs to another user" do
    let(:question) { FactoryGirl.create :question, state: "active" }

    it "doesn't change the question" do
      expect(Question.find(question.id).state).to eq "active"
    end

    it "responds with an error" do
      expect(json['error_code']).to eq 2005
      expect(json['error_message']).to match /Question does not belong to you./
    end
  end
end
