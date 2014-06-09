require 'spec_helper'

describe Friendship do
  let(:user) { FactoryGirl.create(:user) }
  let(:friend) { FactoryGirl.create(:user) }
  let(:friendship) { user.friendships.build(friend_id: friend.id, status: "accepted") }

  subject { friendship }

  it { should be_valid }

  describe "friendship methods" do
  	it { should respond_to(:user) }
  	it { should respond_to(:friend) }
  	its(:user) { should eq user }
  	its(:friend) { should eq friend }
  end

  describe "when user id is not present" do
  	before { friendship.user_id = nil }
  	it { should_not be_valid }
  end

  describe "when friend id is not present" do
  	before { friendship.friend_id = nil }
  	it { should_not be_valid }
  end
end
