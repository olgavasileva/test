require 'spec_helper'

describe Category do
  
	before { @category = Category.new(name: "a test category") }

	subject { @category }

	it { should respond_to(:name) }
	it { should respond_to(:questions) }

	describe "with blank name" do
		before { @category.name = " " }
		it { should_not be_valid }
	end

	describe "question associations" do
		before { @category.save }

		let!(:user) { FactoryGirl.create(:user) }
		let!(:question) { FactoryGirl.create(:question, user: user, category: @category) }
		let!(:another_question) { FactoryGirl.create(:question, user: user, category: @category) }
		let!(:other_category) { FactoryGirl.create(:category) }
		let!(:other_question) { FactoryGirl.create(:question, user: user, category: other_category) }

		its(:questions) { should include(question) }
		its(:questions) { should include(another_question) }
		its(:questions) { should_not include(other_question) }

		describe "a questions user" do
			subject { question }
			its(:user) { should eq user }
		end

		describe "a questions category" do
			subject { question }
			its(:category) { should eq @category }
		end

		it "should destroy associated questions" do
			questions = @category.questions.to_a
			@category.destroy
			expect(questions).not_to be_empty
			questions.each do |question|
				expect(Question.where(id: question.id)).to be_empty
			end
		end
	end

end
