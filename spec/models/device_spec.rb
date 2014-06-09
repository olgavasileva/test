require 'spec_helper'

describe Device do

	before do
		@device = Device.new(udid: "NOT_A_REAL_UDID", device_type: "iPad3,2", os_version: "5.1.1")
	end

	subject { @device }

	it { should respond_to(:udid) }
	it { should respond_to(:device_type) }
	it { should respond_to(:os_version) }
	it { should respond_to(:ownerships) }
	it { should respond_to(:owned_by?) }

	describe "when udid is not present" do
    before { @device.udid = " " }
    it { should_not be_valid }
  end

  describe "when device_type is not present" do
    before { @device.device_type = " " }
    it { should_not be_valid }
  end

  describe "when os_version is not present" do
    before { @device.os_version = " " }
    it { should_not be_valid }
  end

	describe "being owned" do
		let (:user) { FactoryGirl.create(:user) }
		before do
			@device.save
			user.own!(@device)
		end

		specify { expect(@device).to be_owned_by(user) }
		its(:users) { should include(user) }

		describe "owning user" do
			subject { user }
			its(:devices) { should include(@device) }
		end

		describe "and disowning" do
			before { user.disown!(@device) }

			it { should_not be_owned_by(user) }
			its(:users) { should_not include(user) }
		end

		it "should destroy associated ownerships" do
			ownerships = @device.ownerships.to_a
			@device.destroy
			expect(ownerships).not_to be_empty
			ownerships.each do |ownership|
				expect(Ownership.where(id: ownership.id)).to be_empty
			end
		end
	end

end
