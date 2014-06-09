require 'spec_helper'

describe Response do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:category) { FactoryGirl.create(:category) }
	let(:question) { FactoryGirl.create(:question, user: user, category: category) }
	let(:choice) { FactoryGirl.create(:choice, question: question) }
	let(:answer) { FactoryGirl.create(:answer, user: user, question: question) }

	before { @response = answer.responses.build(order: 1, percent: 0.5, star: 2, choice: choice, answer: answer) }

	subject { @response }

	it { should respond_to(:order) }
	it { should respond_to(:percent) }
	it { should respond_to(:star) }
	it { should respond_to(:choice_id) }
	it { should respond_to(:answer_id) }
	its(:choice) { should eq choice }
	its(:answer) { should eq answer }

	describe "when choice_id is not present" do
		before { @response.choice_id = nil }
		it { should_not be_valid }
	end

	describe "when answer_id is not present" do
		before { @response.answer_id = nil }
		it { should_not be_valid }
	end


end
