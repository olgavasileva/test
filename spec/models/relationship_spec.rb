require 'rails_helper'

describe Relationship do

  let(:follower) { FactoryGirl.create(:user) }
  let(:leader) { FactoryGirl.create(:user) }
  let!(:relationship) { follower.followership_relationships.create(leader_id: leader.id) }

  subject { relationship }

  it { expect(relationship).to be_valid }

  describe "follower methods" do
    it { relationship.should respond_to(:follower) }
    it { relationship.should respond_to(:leader) }
    it { relationship.follower.should eq follower }
    it { relationship.leader.should eq leader }
  end

  describe "when leader id is not present" do
    before { relationship.leader_id = nil }
    it { relationship.should_not be_valid }
  end

  describe "when follower id is not present" do
    before { relationship.follower_id = nil }
    it { relationship.should_not be_valid }
  end

  describe :groups do
    let(:groups) { FactoryGirl.create_list(:group, 3, user: leader) }

    before { groups[1].member_users << follower }

    it "returns groups created by leader with follower as member" do
      expect(relationship.groups).to match_array [groups[1]]
    end
  end
end
