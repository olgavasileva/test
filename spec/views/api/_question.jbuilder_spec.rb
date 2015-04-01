require 'rails_helper'

RSpec.describe 'api/_question_summary.jbuilder' do
  let(:user) { FactoryGirl.build(:user, id: 1) }

  let(:question) do
    FactoryGirl.build(:text_choice_question, {
      id: 1,
      user: user,
      description: 'Awesome cool question',
      anonymous: true,
      uuid: "Qtest-uuid",
      min_responses: 2,
      max_responses: 4,
      survey_id: 1,
      tag_list: %w{tag1 tag2},
      rotate: true
    })
  end

  before do
    allow(view).to receive(:current_user) { user }

    allow(question).to receive(:kind_of?).and_call_original
    allow(question).to receive(:response_count) { 20 }
    allow(question).to receive(:comment_count) { 20 }
  end

  let(:json) do
    render partial: 'api/question', locals: {question: question}
    JSON.parse(rendered)
  end

  subject { json }

  it { is_expected.to have_json_key(:id).eq(question.id) }
  it { is_expected.to have_json_key(:title).eq(question.title) }
  it { is_expected.to have_json_key(:description).eq(question.description) }
  it { is_expected.to have_json_key(:response_count).eq(question.response_count) }
  it { is_expected.to have_json_key(:comment_count).eq(question.comment_count) }
  it { is_expected.to have_json_key(:uuid).eq(question.uuid) }
  it { is_expected.to have_json_key(:created_at) }
  it { is_expected.to have_json_key(:tags).eq(question.tag_list) }
  it { is_expected.to have_json_key(:image_url).eq(question.device_image_url) }

  it { is_expected.to have_json_key(:creator_id).eq(user.id) }
  it { is_expected.to have_json_key(:creator_name).eq(user.username) }

  it { is_expected.to have_json_key(:survey_id).eq(question.survey_id) }

  it { is_expected.to have_json_key(:choices).eq([]) }
  it { is_expected.to have_json_key(:category) }
  it { is_expected.to have_json_key(:member_community_ids).eq([]) }

  context ':type' do
    context 'when question is a YesNoQuestion' do
      before do
        expect(question).to receive(:kind_of?).with(YesNoQuestion) { true }
      end

      it { is_expected.to have_json_key(:type).eq('TextChoiceQuestion') }
    end

    context 'when question is not a YesNoQuestion' do
      it { is_expected.to have_json_key(:type).eq(question.type) }
    end
  end

  context ':rotate' do
    context 'when question is a type of ChoiceQuestion' do
      it { is_expected.to have_json_key(:rotate).eq(question.rotate) }
    end

    context 'when question is not a type of ChoiceQuestion' do
      before do
        allow(question).to receive(:kind_of?).with(ChoiceQuestion) { false }
      end

      it { is_expected.to_not have_json_key(:rotate) }
    end
  end

  context ':min/max_responses' do
    context 'when question is a type of MultipleChoiceQuestion' do
      before do
        expect(question).to receive(:kind_of?)
          .with(MultipleChoiceQuestion)
          .and_return(true)
      end

      it { is_expected.to have_json_key(:max_responses) }
      it { is_expected.to have_json_key(:min_responses) }
    end

    context 'when question is not a type of MultipleChoiceQuestion' do
      it { is_expected.to_not have_json_key(:max_responses) }
      it { is_expected.to_not have_json_key(:min_responses) }
    end
  end

  context ':creator_avatar_url' do
    context 'when the user has an avatar' do
      before do
        user.avatar = FactoryGirl.build(:user_avatar, user: user)
      end

      it { is_expected.to have_json_key(:creator_avatar_url)
            .eq(user.avatar.image_url) }
    end

    context 'when the user does not have an avatar' do
      it { is_expected.to have_json_key(:creator_avatar_url)
            .eq(view.gravatar_url(user.email, default: :identicon)) }
    end
  end

  context ':user_answered' do
    context 'when @answered_questions is available' do
      before { assign(:answered_questions, {}) }
      it { is_expected.to have_json_key(:user_answered) }
    end

    context 'when @answered_questions is not available' do
      it { is_expected.to_not have_json_key(:user_answered) }
    end
  end

  context ':text_type and :min/max_characters' do
    context 'when question is a type of TextQuestion' do
      before do
        expect(question).to receive(:kind_of?)
          .with(TextQuestion)
          .and_return(true)
      end

      it { is_expected.to have_json_key(:text_type) }
      it { is_expected.to have_json_key(:max_characters) }
      it { is_expected.to have_json_key(:min_characters) }
    end

    context 'when question is not a type of TextQuestion' do
      it { is_expected.to_not have_json_key(:text_type) }
      it { is_expected.to_not have_json_key(:max_characters) }
      it { is_expected.to_not have_json_key(:min_characters) }
    end
  end

  context ':category object' do
    subject { json['category'] }
    it { is_expected.to have_json_key(:id) }
    it { is_expected.to have_json_key(:name) }
  end
end
