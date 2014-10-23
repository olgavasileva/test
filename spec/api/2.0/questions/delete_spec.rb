require 'rails_helper'

describe 'DELETE /questions' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.auth_token,
    id: question.id
  } }

  before { delete 'v/2.0/questions', params }

  it "destroys the question" do
    expect(Question.find_by_id(question.id)).to be_nil
  end

  it "responds with blank data" do
    expect(JSON.parse(response.body)).to eq Hash.new
  end
end
