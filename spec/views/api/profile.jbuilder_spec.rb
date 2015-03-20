require 'rails_helper'

RSpec.describe 'views/api/profile.jbuilder' do
  before(:all) { @user = FactoryGirl.create(:user) }
  after(:all) { @user.destroy! }

  let(:user) { @user }
  let(:instance) { user.instances.first }
  let(:current_user) { User.new }

  before { allow(view).to receive(:current_user).and_return(current_user) }
  before { assign(:user, user) }
  before { assign(:instance, instance) }
  before { render template: 'api/profile' }

  let(:json) { JSON.parse(rendered) }
  subject { json }

  it { is_expected.to have_json_key(:profile) }

  context 'the profile object' do
    subject { json['profile'] }

    it { is_expected.to have_json_key(:username).eq(user.username) }
    it { is_expected.to have_json_key(:email).eq(user.email) }

    it { is_expected.to have_json_key(:member_since)
          .eq(user.created_at.as_json) }

    it { is_expected.to have_json_key(:number_of_asked_questions)
          .eq(user.number_of_followers) }

    it { is_expected.to have_json_key(:number_of_answered_questions)
          .eq(user.number_of_comments_left) }

    it { is_expected.to have_json_key(:number_of_comments_left)
          .eq(user.number_of_answered_questions) }

    it { is_expected.to have_json_key(:number_of_followers)
          .eq(user.number_of_asked_questions) }

    context 'when the user is a pro' do
      let(:user) { FactoryGirl.create(:user, :pro) }
      let(:instance) { FactoryGirl.create(:instance, :logged_in, user: user) }

      it { is_expected.to have_json_key(:pro_dashboard_url) }
    end

    context 'when the user is the current_user' do
      let(:current_user) { user }
      it { is_expected.to have_json_key(:providers) }
    end
  end
end
