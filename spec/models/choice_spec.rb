require 'spec_helper'

describe Choice do
  
	let(:user) { FactoryGirl.create(:user) }
	let(:category) { FactoryGirl.create(:category) }
	let(:question) { FactoryGirl.create(:question, user: user, category: category) }

	before { @choice = question.choices.build(label: "test choice", image_url: "http://example.com/test.png", description: "a test choice description") }

	subject { @choice }

	it { should respond_to(:label) }
	it { should respond_to(:image_url) }
	it { should respond_to(:description) }
	it { should respond_to(:question_id) }
	its(:question) { should eq question }

	describe "when question_id is not present" do
		before { @choice.question_id = nil }
		it { should_not be_valid }
	end

	describe "response associations" do
		before { @choice.save }

		let!(:answer) { FactoryGirl.create(:answer, user: user, question: question) }
		let!(:response) { FactoryGirl.create(:response, choice: @choice, answer: answer) }
		let(:other_user) { FactoryGirl.create(:user) }
		let!(:other_answer) { FactoryGirl.create(:answer, user: other_user, question: question) }
		let!(:other_choice) { FactoryGirl.create(:choice, question: question) }
		let!(:other_response) { FactoryGirl.create(:response, choice: other_choice, answer: other_answer) }

		its(:responses) { should include(response) }
		its(:responses) { should_not include(other_response) }

		describe "a responses choice" do
			subject { response }
			its(:choice) { should eq @choice }
		end

		describe "a responses answer" do
			subject { response }
			its(:answer) { should eq answer }
		end

		it "should destroy associated responses" do
			responses = @choice.responses.to_a
			@choice.destroy
			expect(responses).not_to be_empty
			responses.each do |response|
				expect(Response.where(id: response.id)).to be_empty
			end
		end
	end

end
