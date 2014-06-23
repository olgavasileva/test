require 'spec_helper'

describe "API Access MicropostsContoller" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:device) { FactoryGirl.create(:device) }
	let(:ownership) { user.own!(device) }
	let(:another_user) { FactoryGirl.create(:user) }

	describe "MicropostsContoller methods" do

		describe "accessing create action" do
			describe "without proper authorization" do
				before do
					params = { micropost: { content: "an API post" }, format: :json }
					post "api/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token", micropost: { content: "an API post" }, format: :json }
					post "api/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token", micropost: { content: "an API post" }, format: :json }
					post "api/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with invalid information" do
				before do
					params = { micropost: { content: "a" * 141 }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/microposts", params
				end
				specify { response.should_not be_success }
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('is too long') }
			end

			describe "with valid micropost creation" do
				before do
					params = { micropost: { content: "an API post" }, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/microposts", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('content') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match('an API post') }	
				specify { expect(response.body).not_to match('user_id') }	
			end
		end


		describe "accessing destroy action" do
			before do
				@micropost = user.microposts.build(content: "an API post")
				@micropost.save
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					delete "api/microposts/#{@micropost.id}", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token", format: :json }
					delete "api/microposts/#{@micropost.id}", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token", format: :json }
					delete "api/microposts/#{@micropost.id}", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with an incorrect user" do
				before do
					incorrect_user = FactoryGirl.create(:user)
					incorrect_user.save
					incorrect_ownership = incorrect_user.own!(device)
					params = { udid: device.udid, remember_token: incorrect_ownership.remember_token, format: :json }
					delete "api/microposts/#{@micropost.id}", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: user cannot delete another users micropost, access denied') }
			end

			describe "with valid micropost deletion" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					delete "api/microposts/#{@micropost.id}", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('micropost successfully destroyed') }
			end

			it "should be able to delete a micropost and decrement the count" do
				expect do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
						delete "api/microposts/#{@micropost.id}", params
				end.to change(Micropost, :count).by(-1)
			end
		end


		describe "accessing user_feed action" do
			let(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
			let(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
			let(:m3) { FactoryGirl.create(:micropost, user: another_user, content: "Baz") }
			let(:m4) { FactoryGirl.create(:micropost, user: another_user, content: "Bat") }
			let(:unfollowed_user) { FactoryGirl.create(:user) }
			let(:m5) { FactoryGirl.create(:micropost, user: unfollowed_user, content: "bad post 1") }
			let(:m6) { FactoryGirl.create(:micropost, user: unfollowed_user, content: "bad post 2") }
			before do
				unfollowed_user.save
				m1.save
				m2.save
				m3.save
				m4.save
				m5.save
				m6.save
				user.follow!(another_user)
			end
			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/microposts/user_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/microposts/user_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/microposts/user_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/microposts/user_feed", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, page: 1, format: :json }
					post "api/microposts/user_feed", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('content') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{m1.content}") }
				specify { expect(response.body).to match("#{m2.content}") }
				specify { expect(response.body).to match("#{m3.content}") }
				specify { expect(response.body).to match("#{m4.content}") }
				specify { expect(response.body).to match("#{user.name}") }
				specify { expect(response.body).to match("#{another_user.name}") }
				specify { expect(response.body).not_to match("#{m5.content}") }
				specify { expect(response.body).not_to match("#{m6.content}") }
				specify { expect(response.body).not_to match("#{unfollowed_user.name}") }
			end
		end
	end


end