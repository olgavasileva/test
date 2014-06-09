require 'spec_helper'

describe Sharing do
  let(:sender) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  let(:question) { FactoryGirl.create(:question) }
  let(:sharing) { sender.sharings.build(receiver_id: receiver.id, question_id: question.id) }

  subject { sharing }

  it { should be_valid }

  describe "sharing methods" do
  	it { should respond_to(:sender) }
  	it { should respond_to(:receiver) }
  	it { should respond_to(:question) }
  	its(:sender) { should eq sender }
  	its(:receiver) { should eq receiver }
  	its(:question) { should eq question }
  end

  describe "when sender id is not present" do
  	before { sharing.sender_id = nil }
  	it { should_not be_valid }
  end

  describe "when receiver id is not present" do
  	before { sharing.receiver_id = nil }
  	it { should_not be_valid }
  end

  describe "when question id is not present" do
  	before { sharing.question_id = nil }
  	it { should_not be_valid }
  end
end
