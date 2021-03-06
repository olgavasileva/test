require 'rails_helper'

RSpec.describe ShortLinksController do

  describe 'GET #latest_question' do
    let!(:inactive) { FactoryGirl.create(:question, state: 'suspended') }
    let!(:non_public) { FactoryGirl.create(:question, kind: 'targeted', user: inactive.user) }
    let!(:older) { FactoryGirl.create(:question, user: inactive.user)}
    let!(:question) { FactoryGirl.create(:question, user: inactive.user) }

    before do
      older.update_column(:created_at, 1.day.ago)
      question.update_column(:created_at, 1.hour.ago)
    end

    it 'redirects the current question on the web app' do
      get :latest_question
      expected_url = "#{ENV['WEB_APP_URL']}/#/app/questions/#{question.id}"
      expect(response).to redirect_to(expected_url)
    end
  end
end
