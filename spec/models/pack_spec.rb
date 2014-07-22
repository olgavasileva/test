require 'rails_helper'

describe Pack do

  let(:user) { FactoryGirl.create(:user) }
  before { @pack = user.packs.build(title: "Lorem ipsum") }

  subject { @pack }

  it { should respond_to(:title) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { @pack.user.should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @pack.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank title" do
    before { @pack.title = " " }
    it { should_not be_valid }
  end

  describe "including" do
  	let (:question) { FactoryGirl.create(:question) }
  	let (:another_question) { FactoryGirl.create(:question) }
  	before do
  		@pack.save
  		@pack.include_question!(question)
  		@pack.include_question!(another_question)
  	end

  	specify { expect(@pack).to be_includer_of(question) }
  	it { @pack.questions.should include(question) }

  	describe "included question" do
  		it { question.packs.should include(@pack) }
  	end

  	describe "and disincluding" do
  		before { @pack.disinclude_question!(question) }

  		it { should_not be_includer_of(question) }
  		it { @pack.questions.should_not include(question) }
  	end

  	it "should destroy associated inclusions" do
  		inclusions = @pack.inclusions.to_a
  		@pack.destroy
  		expect(inclusions).not_to be_empty
  		inclusions.each do |inclusion|
  			expect(Inclusion.where(id: inclusion.id)).to be_empty
  		end
  	end
  end
end
