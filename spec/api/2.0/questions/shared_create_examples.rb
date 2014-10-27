shared_examples :uses_targets do
  let(:followers) { user.followers = FactoryGirl.create_list(:user, 3) }
  let(:groups) { FactoryGirl.create_list(:group, 3, user: user) }
  let(:targets) {{
    all_users: true,
    all_followers: true,
    all_groups: true,
    follower_ids: followers.map(&:id),
    group_ids: groups.map(&:id)
  }}
  let(:question_id) { JSON.parse(response.body)['question']['id'] }
  let(:question) { Question.find(question_id) }

  it "creates a target for question" do
    target = Target.last

    expect(target).to_not be_nil
    expect(target.all_users).to be_truthy
    expect(target.all_followers).to be_truthy
    expect(target.all_groups).to be_truthy
    expect(target.followers).to match_array followers
    expect(target.groups).to match_array groups
    expect(target.questions).to include question
  end

  it "adds feed item to targeted users" do
    user.followers.each do |follower|
      expect(follower.feed_items.map(&:question_id)).to include question_id
    end
  end

  context "with `all` target param" do
    let(:targets) {{
      all: true
    }}

    it "creates a target for all users" do
      target = Target.last

      expect(target.all_users).to be_truthy
    end
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
