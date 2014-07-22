require 'rails_helper'

describe Friendship do
  let(:user) { FactoryGirl.create(:user) }
  let(:friend) { FactoryGirl.create(:user) }
  let(:friendship) { user.friendships.build(friend_id: friend.id, status: "accepted") }

  it { friendship.should be_valid }

  describe "friendship methods" do
  	it { friendship.should respond_to(:user) }
  	it { friendship.should respond_to(:friend) }
  	it { friendship.user.should eq user }
  	it { friendship.friend.should eq friend }
  end

  describe "when user id is not present" do
  	before { friendship.user_id = nil }
  	it { friendship.should_not be_valid }
  end

  describe "when friend id is not present" do
  	before { friendship.friend_id = nil }
  	it { friendship.should_not be_valid }
  end
end
