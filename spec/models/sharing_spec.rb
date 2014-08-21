require 'rails_helper'

describe Sharing do
  let(:sender) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  let(:question) { FactoryGirl.create(:question) }
  let(:sharing) { sender.sharings.build(receiver_id: receiver.id, question_id: question.id) }

  it { expect(sharing).to be_valid }

  describe "sharing methods" do
  	it { sharing.should respond_to(:sender) }
  	it { sharing.should respond_to(:receiver) }
  	it { sharing.should respond_to(:question) }
  	it { expect(sharing.sender).to eq sender }
  	it { sharing.receiver.should eq receiver }
  	it { sharing.question.should eq question }
  end

  describe "when sender id is not present" do
  	before { sharing.sender = nil }
  	it { sharing.should_not be_valid }
  end

  describe "when receiver id is not present" do
  	before { sharing.receiver = nil }
  	it { sharing.should_not be_valid }
  end

  describe "when question id is not present" do
  	before { sharing.question = nil }
  	it { sharing.should_not be_valid }
  end
end
