require 'rails_helper'

describe 'GET questions/question' do
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
    auth_token: instance.auth_token,
    question_id: question.id
  } }
  let(:response_body) { JSON.parse(response.body) }
  before { get 'v/2.0/questions/question', params }

  describe "response with all question data" do
    it {expect(response_body.keys).to match_array %w(category choices comment_count creator_id creator_name description id response_count summary title type user_answered uuid image_url created_at)}
    it {expect(response_body["category"].keys).to match_array %w(id name)}
    it {expect(response_body["summary"].keys).to match_array %w(anonymous choices comment_count creator_id creator_name published_at response_count share_count skip_count sponsor view_count start_count)}
  end

  context "When supplying the quetion uuid in stead of the id" do
    let(:params) { {
      auth_token: instance.auth_token,
      question_uuid: question.uuid
    } }

    describe "response with all question data" do
      it {expect(response_body.keys).to match_array %w(category choices comment_count creator_id creator_name description id response_count summary title type user_answered uuid image_url created_at)}
      it {expect(response_body["category"].keys).to match_array %w(id name)}
      it {expect(response_body["summary"].keys).to match_array %w(anonymous choices comment_count creator_id creator_name published_at response_count share_count skip_count sponsor view_count start_count)}
    end
  end
end
