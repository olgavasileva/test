require 'rails_helper'

describe Inclusion do

	let (:pack) { FactoryGirl.create(:pack) }
	let (:question) { FactoryGirl.create(:question) }
	let (:inclusion) { pack.inclusions.build(question_id: question.id) }

	it { expect(inclusion).to be_valid }

	describe "inclusion methods" do
		it { inclusion.should respond_to(:pack) }
		it { inclusion.should respond_to(:question) }
		it { inclusion.pack.should eq pack }
		it { inclusion.question.should eq question }
	end

	describe "when pack id is not present" do
		before { inclusion.pack = nil }
		it { inclusion.should_not be_valid }
	end

	describe "when question id is not present" do
		before { inclusion.question = nil }
		it { inclusion.should_not be_valid }
	end
end
