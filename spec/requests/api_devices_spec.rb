require 'spec_helper'

describe "API Access DevicesController" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:device) { FactoryGirl.create(:device) }
	let(:ownership) { user.own!(device) }
	let(:another_user) { FactoryGirl.create(:user) }

	describe "DevicesController methods" do
		
		before do
			@deviceuser = User.new(username: "exampleuser", name: "Example User", email: "user@example.com", password: "foobar69", password_confirmation: "foobar69")
		end

		describe "accessing create action" do
			describe "without proper user login info" do
				before do
					params = { session: { udid: "NOT_A_REAL_UDID_1000", device_type: "iPad5,2", os_version: "7.0.3", email: "fakeuser@example.com", password: "fakepassword" }, format: :json }
					post "api/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: invalid email/password combination, access denied') }	
			end

			describe "with incorrect params" do
				before do
					@deviceuser.save!
					params = { session: { email: @deviceuser.email, password: "foobar69" } }
					post "api/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with proper authorization" do
				before do
					@deviceuser.save!
					params = { session: { udid: "NOT_A_REAL_UDID_1000", device_type: "iPad5,2", os_version: "7.0.3", email: @deviceuser.email, password: "foobar69" }, format: :json }
					post "api/devices", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('remember_token') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('device_id') }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('username') }
			end
		end
	end

end