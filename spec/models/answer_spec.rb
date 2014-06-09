require 'spec_helper'

describe Answer do
  
	let(:ask_user) { FactoryGirl.create(:user) }
	let(:answer_user) { FactoryGirl.create(:user) }
	let(:category) { FactoryGirl.create(:category) }
	let(:question) { FactoryGirl.create(:question, user: ask_user, category: category) }
	before { @answer = answer_user.answers.build(agree: true, question: question) }

	subject { @answer }

	it { should respond_to(:agree) }
	it { should respond_to(:user_id) }
	it { should respond_to(:question_id) }
	its(:user) { should eq answer_user }
	its(:user) { should_not eq ask_user }
	its(:question) { should eq question }
	it { should respond_to(:responses) }

	describe "when user_id is not present" do
		before { @answer.user_id = nil }
		it { should_not be_valid }
	end

	describe "when question_id is not present" do
		before { @answer.question_id = nil }
		it { should_not be_valid }
	end

	describe "response associations" do
		before { @answer.save }

		let!(:choice) { FactoryGirl.create(:choice, question: question) }
		let!(:response) { FactoryGirl.create(:response, choice: choice, answer: @answer) }
		let!(:other_answer) { FactoryGirl.create(:answer, user: ask_user, question: question) }
		let!(:other_choice) { FactoryGirl.create(:choice, question: question) }
		let!(:other_response) { FactoryGirl.create(:response, choice: other_choice, answer: other_answer) }

		its(:responses) { should include(response) }
		its(:responses) { should_not include(other_response) }

		describe "a responses choice" do
			subject { response }
			its(:choice) { should eq choice }
		end

		describe "a responses answer" do
			subject { response }
			its(:answer) { should eq @answer }
		end

		it "should destroy associated responses" do
			responses = @answer.responses.to_a
			@answer.destroy
			expect(responses).not_to be_empty
			responses.each do |response|
				expect(Response.where(id: response.id)).to be_empty
			end
		end
	end

end
