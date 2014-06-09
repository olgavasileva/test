require 'spec_helper'

describe Ownership do
  
	let (:user) { FactoryGirl.create(:user) }
	let (:device) { FactoryGirl.create(:device) }
	let (:ownership) { user.ownerships.build(device_id: device.id) }

	subject { ownership }

	it { should be_valid }

	describe "possession methods" do
		it { should respond_to(:user) }
		it { should respond_to(:device) }
		its(:user) { should eq user }
		its(:device) { should eq device }
	end

	describe "when user id is not present" do
		before { ownership.user_id = nil }
		it { should_not be_valid }
	end

	describe "when device id is not present" do
		before { ownership.device_id = nil }
		it { should_not be_valid }
	end

	describe "remember token" do
		before { ownership.save }
    	its(:remember_token) { should_not be_blank }
  	end

end
