shared_examples :uses_targets do
  let(:followers) { user.followers = FactoryGirl.create_list(:user, 3) }
  let(:groups) { FactoryGirl.create_list(:group, 3, user: user) }
  let(:targets) {{
    all: true,
    all_followers: true,
    all_groups: true,
    follower_ids: followers.map(&:id),
    group_ids: groups.map(&:id)
  }}
  let(:question_id) { JSON.parse(response.body)['question']['id'] }
  let(:question) { Question.find(question_id) }

  it "uses targets data for new question" do
    expect(question.target_all).to be_truthy
    expect(question.target_all_followers).to be_truthy
    expect(question.target_all_groups).to be_truthy
    expect(question.target_followers).to match_array followers
    expect(question.target_groups).to match_array groups
  end
end

shared_examples :uses_anonymous do
  let(:anonymous) { false }
  let(:question_id) { JSON.parse(response.body)['question']['id'] }
  let(:question) { Question.find(question_id) }

  context "with anonymous flag" do
    let(:anonymous) { true }

    it "sets anonymous flag for new question" do
      expect(question.anonymous).to be_truthy
    end
  end
end
