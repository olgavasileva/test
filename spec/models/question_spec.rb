require 'spec_helper'

describe Question do

	let(:user) { FactoryGirl.create(:user) }
	let(:category) { FactoryGirl.create(:category) }
	before { @question = user.questions.build(title: "test question", info: "test info", image_url: "http://example.com/image.png", question_type: 1, category: category) }

	subject { @question }

	it { should respond_to(:title) }
	it { should respond_to(:info) }
	it { should respond_to(:image_url) }
	it { should respond_to(:question_type) }
	it { should respond_to(:category_id) }
	it { should respond_to(:user_id) }
	its(:user) { should eq user }
	it { should respond_to(:choices) }
	it { should respond_to(:answers) }
	it { should respond_to(:comments) }
	it { should respond_to(:sharings) }
	it { should respond_to(:hidden) }
	it { should respond_to(:special_case) }
	it { should respond_to(:sponsored) }

	describe "when user_id is not present" do
		before { @question.user_id = nil }
		it { should_not be_valid }
	end

	describe "when category_id is not present" do
		before { @question.category_id = nil }
		it { should_not be_valid }
	end

	describe "with blank title" do
		before { @question.title = " " }
		it { should_not be_valid }
	end

	describe "choice associations" do
		before { @question.save }

		let!(:choice) { FactoryGirl.create(:choice, question: @question) }
		let!(:another_choice) { FactoryGirl.create(:choice, question: @question) }
		let!(:other_question) { FactoryGirl.create(:question, user: user, category: category) }
		let!(:other_choice) { FactoryGirl.create(:choice, question: other_question) }

		its(:choices) { should include(choice) }
		its(:choices) { should include(another_choice) }
		its(:choices) { should_not include(other_choice) }

		describe "a choices question" do
			subject { choice }
			its(:question) { should eq @question }
		end

		it "should destroy associated choices" do
			choices = @question.choices.to_a
			@question.destroy
			expect(choices).not_to be_empty
			choices.each do |choice|
				expect(Choice.where(id: choice.id)).to be_empty
			end
		end

	end

	describe "answer associations" do
		before { @question.save }

		let!(:another_user) { FactoryGirl.create(:user) }
		let!(:answer) { FactoryGirl.create(:answer, user: user, question: @question) }
		let!(:another_answer) { FactoryGirl.create(:answer, user: another_user, question: @question) }
		let!(:other_question) { FactoryGirl.create(:question, user: user, category: category) }
		let!(:other_answer) { FactoryGirl.create(:answer, user: user, question: other_question) }

		its(:answers) { should include(answer) }
		its(:answers) { should include(another_answer) }
		its(:answers) { should_not include(other_answer) }

		describe "an answers user" do
			subject { answer }
			its(:user) { should eq user}
		end

		describe "an answers question" do
			subject { answer }
			its(:question) { should eq @question }
		end

		it "should destroy associated answers" do
			answers = @question.answers.to_a
			@question.destroy
			expect(answers).not_to be_empty
			answers.each do |answer|
				expect(Answer.where(id: answer.id)).to be_empty
			end
		end
	end

	describe "being included" do
		let (:pack) { FactoryGirl.create(:pack) }
		before do
			@question.save
			pack.include_question!(@question)
		end

		specify { expect(@question).to be_included_by(pack) }
		its(:packs) { should include(pack) }

		describe "including pack" do
			subject { pack }
			its(:questions) { should include(@question) }
		end

		describe "and disincluding" do
			before { pack.disinclude_question!(@question) }

			it { should_not be_included_by(pack) }
			its(:packs) { should_not include(pack) }
		end

		it "should destroy associated inclusions" do
			inclusions = @question.inclusions.to_a
			@question.destroy
			expect(inclusions).not_to be_empty
			inclusions.each do |inclusion|
				expect(Inclusion.where(id: inclusion.id)).to be_empty
			end
		end
	end

	describe "comment associations" do
    before { @question.save }

    let!(:user) { FactoryGirl.create(:user) }
    let!(:other_question) { FactoryGirl.create(:question, user: user) }
    let!(:comment) { FactoryGirl.create(:comment, user: user, question: @question) }
    let!(:another_comment) { FactoryGirl.create(:comment, user: user, question: @question) }
    let!(:other_comment) { FactoryGirl.create(:comment, user: user, question: other_question) }

    its(:comments) { should include(comment) }
    its(:comments) { should include(another_comment) }
    its(:comments) { should_not include(other_comment) }

    describe "a comments questions" do
      subject { comment }
      its(:question) { should eq @question }
      its(:question) { should_not eq other_question }
    end

    it "should destroy associated comments" do
      comments = @question.comments.to_a
      @question.destroy
      expect(comments).not_to be_empty
      comments.each do |comment|
        expect(Comment.where(id: comment.id)).to be_empty
      end
    end
  end

  describe "sharing associations" do
  	before { @question.save }

  	let!(:sender) { FactoryGirl.create(:user) }
  	let!(:receiver) { FactoryGirl.create(:user) }
  	let!(:sharing) { FactoryGirl.create(:sharing, sender: sender, receiver: receiver, question: @question) }
  	let!(:other_question) { FactoryGirl.create(:question, user: sender) }
  	let!(:other_sharing) { FactoryGirl.create(:sharing, sender: sender, receiver: receiver, question: other_question) }

  	its(:sharings) { should include(sharing) }
  	its(:sharings) { should_not include(other_sharing) }

  	describe "a sharings questions" do
  		subject { sharing }
  		its(:question) { should eq @question }
  		its(:question) { should_not eq other_question }
  	end

  	it "should destroy associated sharings" do
  		sharings = @question.sharings.to_a
  		@question.destroy
  		expect(sharings).not_to be_empty
  		sharings.each do |sharing|
  			expect(Sharing.where(id: sharing.id)).to be_empty
  		end
  	end
  end


end














