require 'rails_helper'

describe Relationship do

  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { expect(relationship).to be_valid }

  describe "follower methods" do
    it { relationship.should respond_to(:follower) }
    it { relationship.should respond_to(:followed) }
    it { relationship.follower.should eq follower }
    it { relationship.followed.should eq followed }
  end

  describe "when followed id is not present" do
    before { relationship.followed_id = nil }
    it { relationship.should_not be_valid }
  end

  describe "when follower id is not present" do
    before { relationship.follower_id = nil }
    it { relationship.should_not be_valid }
  end
end