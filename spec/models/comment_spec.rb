require 'spec_helper'

describe Comment do
  let(:user) { FactoryGirl.create(:user) }
  let(:question) { FactoryGirl.create(:question, user: user) }
  
  before { @comment = user.comments.build(content: "Lorem ipsum", question: question) }

  subject { @comment }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:question_id) }
  its(:user) { should eq user }
  its(:question) { should eq question }

  describe "when user_id is not present" do
  	before { @comment.user_id = nil }
  	it { should_not be_valid }
  end

  describe "when question_id is not present" do
  	before { @comment.question_id = nil }
  	it { should_not be_valid }
  end

  describe "with blank content" do
  	before { @comment.content = " " }
  	it { should_not be_valid }
  end

  describe "with content that is too long" do
  	before { @comment.content = "a" * 141 }
  	it { should_not be_valid }
  end
end
