require 'rails_helper'

RSpec.describe 'api/_question_summary.jbuilder' do
  let(:current_user) { FactoryGirl.build(:user, id: 1) }

  # ----------------------------------------------------------------------------
  # Question Setup

  let(:user) { current_user }
  let(:anonymous) { false }
  let(:question) do
    FactoryGirl.build_stubbed(:text_choice_question, {
      user: user,
      anonymous: anonymous,
      view_count: 100,
      share_count: 20,
      start_count: 40,
      created_at: Time.parse('2012-01-01 00:00:00'),
    })
  end

  before do
    allow(question).to receive(:comment_count) { 25 }
    allow(question).to receive(:response_count) { 30 }
    allow(question).to receive(:skip_count) { 50 }
  end

  # ----------------------------------------------------------------------------
  # View Setup

  before { allow(view).to receive(:current_user).and_return(current_user) }
  before { assign(:question, question) }

  # ----------------------------------------------------------------------------
  # Tests

  subject do
    render partial: 'api/question_summary'
    JSON.parse(rendered)
  end

  it { is_expected.to have_json_key(:choices) }
  it { is_expected.to have_json_key(:response_count).eq(question.response_count) }
  it { is_expected.to have_json_key(:view_count) }
  it { is_expected.to have_json_key(:comment_count).eq(question.comment_count) }
  it { is_expected.to have_json_key(:share_count).eq(question.share_count) }
  it { is_expected.to have_json_key(:skip_count).eq(question.skip_count) }
  it { is_expected.to have_json_key(:start_count).eq(question.start_count) }
  it { is_expected.to have_json_key(:published_at).eq(Time.parse('2012-01-01 00:00:00').to_i) }
  it { is_expected.to have_json_key(:sponsor).eq(nil) }

  it { is_expected.to have_json_key(:creator_id).eq(user.id) }
  it { is_expected.to have_json_key(:creator_name).eq(user.name) }
  it { is_expected.to have_json_key(:anonymous).eq(false) }

  context ':view_count' do
    [:view_count, :skip_count, :response_count].each do |a|
      context "when #{a.inspect} is the highest value" do
        before { allow(question).to receive(a).and_return(1000) }
        it { is_expected.to have_json_key(:view_count).eq(question.send(a)) }
      end
    end
  end

  context 'when the question is anonymous' do
    let(:anonymous) { true }

    it { is_expected.to have_json_key(:anonymous).eq(true) }

    context 'and belongs to the current user' do
      it { is_expected.to have_json_key(:creator_id).eq(user.id) }
      it { is_expected.to have_json_key(:creator_name).eq(user.name) }
    end

    context 'and does not belong to the current user' do
      let(:user) { FactoryGirl.build(:user, id: 12) }

      it { is_expected.to_not have_json_key(:creator_id) }
      it { is_expected.to have_json_key(:creator_name).eq('anonymous') }
    end
  end
end
