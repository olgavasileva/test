require 'spec_helper'

describe Inclusion do

	let (:pack) { FactoryGirl.create(:pack) }
	let (:question) { FactoryGirl.create(:question) }
	let (:inclusion) { pack.inclusions.build(question_id: question.id) }

	subject { inclusion }

	it { should be_valid }

	describe "inclusion methods" do
		it { should respond_to(:pack) }
		it { should respond_to(:question) }
		its(:pack) { should eq pack }
		its(:question) { should eq question }
	end

	describe "when pack id is not present" do
		before { inclusion.pack_id = nil }
		it { should_not be_valid }
	end

	describe "when question id is not present" do
		before { inclusion.question_id = nil }
		it { should_not be_valid }
	end
end
