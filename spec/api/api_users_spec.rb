require 'spec_helper'

describe "API Access UsersController" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:device) { FactoryGirl.create(:device) }
	let(:ownership) { user.own!(device) }
	let(:another_user) { FactoryGirl.create(:user) }

	describe "UsersController methods" do

		describe "accessing create action" do
			describe "with incorrect params" do
				before do
					params = { format: :json }
					post "api/users", params
				end
				specify { response.should_not be_success }
				specify { expect(response.body).to match('error') }
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with invalid information" do
				before do
					params = { user: { username: "validuser", name: "Invalid User", email: user.email, password: "123456", password_confirmation: "98765" }, format: :json }
					post "api/users", params
				end
				specify { response.should_not be_success }
				specify { expect(response.body).to match('error') }
				specify { expect(response.body).to match('has already been taken') }
				specify { expect(response.body).to match('is too short') }
				specify { expect(response.body).to match("doesn't match Password") }
			end

			describe "with valid user creation" do
				before do 
					params = { user: { username: "validuser", name: "Valid User", email: "validuser@example.com", password: "foobar69", password_confirmation: "foobar69" }, format: :json }
					post "api/users", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('username') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).not_to match('remember_token') }
				specify { expect(response.body).to match('Valid User') }
				specify { expect(response.body).not_to match('validuser@example.com') }
			end
		end


		describe "accessing register action" do
			describe "with incorrect params" do
				before do
					params = { format: :json }
					post "api/users/register", params
				end
				specify { response.should_not be_success }
				specify { expect(response.body).to match('error') }
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with invalid information" do
				before do
					params = { user: { username: "validuser", name: "Invalid User", email: user.email, password: "123456", password_confirmation: "98765" }, device: { udid: "another_new_device_udid", device_type: "iPad4,5", os_version: "7.0.4" }, format: :json }
					post "api/users/register", params
				end
				specify { response.should_not be_success }
				specify { expect(response.body).to match('error') }
				specify { expect(response.body).to match('has already been taken') }
				specify { expect(response.body).to match('is too short') }
				specify { expect(response.body).to match("doesn't match Password") }
			end

			describe "with valid user registration" do
				before do 
					params = { user: { username: "validuser", name: "Valid User", email: "validuser@example.com", password: "foobar69", password_confirmation: "foobar69" }, device: { udid: "another_new_device_udid", device_type: "iPad4,5", os_version: "7.0.4" }, format: :json }
					post "api/users/register", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('remember_token') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('username') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).to match('Valid User') }
				specify { expect(response.body).not_to match('validuser@example.com') }
			end
		end


		describe "accessing login action" do
			describe "with incorrect params" do
				before do
					params = { format: :json }
					post "api/users/login", params
				end
				specify { response.should_not be_success }
				specify { expect(response.body).to match('error') }
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with valid user login" do
				let(:login_user) { User.new(username: "validuser", name: "Valid User", email: "validuser@example.com", password: "foobar69", password_confirmation: "foobar69") }

				before do 
					login_user.save
					params = { user: { username: "validuser", password: "foobar69" }, device: { udid: "another_new_device_udid", device_type: "iPad4,5", os_version: "7.0.4" }, format: :json }
					post "api/users/login", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }
				specify { expect(response.body).to match('remember_token') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).to match('username') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).to match('Valid User') }
				specify { expect(response.body).not_to match('validuser@example.com') }
			end
		end


		describe "accessing list_index action" do
			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/list_index", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/list_index", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }	
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/list_index", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/list_index", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { page: 1, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/list_index", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).not_to match('remember_token') }
			end
		end


		describe "accessing following action" do
			before { user.follow!(another_user) }

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/#{user.id}/following", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/following", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/#{user.id}/following", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/#{user.id}/following", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { page: 1, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/following", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).not_to match('remember_token') }
				specify { expect(response.body).to match("#{another_user.name}") }
				specify { expect(response.body).not_to match("#{another_user.email}") }
				specify { expect(response.body).not_to match("#{another_user.password_digest}") }
				specify { expect(response.body).not_to match("#{another_user.remember_token}") }
			end
		end


		describe "accessing followers action" do
			before { another_user.follow!(user) }

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/#{user.id}/followers", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/followers", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/#{user.id}/followers", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/#{user.id}/followers", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { page: 1, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/followers", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).not_to match('remember_token') }
				specify { expect(response.body).to match("#{another_user.name}") }
				specify { expect(response.body).not_to match("#{another_user.email}") }
				specify { expect(response.body).not_to match("#{another_user.password_digest}") }
				specify { expect(response.body).not_to match("#{another_user.remember_token}") }
			end
		end


		describe "accessing devices action" do

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/#{user.id}/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/#{user.id}/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/#{user.id}/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "attempting to access another users devices" do
				before do
					params = { page: 1, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{another_user.id}/devices", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: user can only access its own devices, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { page: 1, udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/devices", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('udid') }
				specify { expect(response.body).to match('device_type') }
				specify { expect(response.body).to match('os_version') }
				specify { expect(response.body).not_to match('created_at') }
				specify { expect(response.body).to match("#{device.udid}") }
				specify { expect(response.body).to match("#{device.device_type}") }
				specify { expect(response.body).to match("#{device.os_version}") }
			end
		end


		describe "accessing microposts action" do
			let(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
			let(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
			let(:m3) { FactoryGirl.create(:micropost, user: another_user, content: "Baz") }
			let(:m4) { FactoryGirl.create(:micropost, user: another_user, content: "Bat") }
			before do
				m1.save
				m2.save
				m3.save
				m4.save
			end

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/#{user.id}/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with incorrect params" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{user.id}/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('incorrect params received') }
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/#{user.id}/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/#{user.id}/microposts", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization to view current users microposts" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, page: 1, format: :json }
					post "api/users/#{user.id}/microposts", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('content') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).to match("#{m1.content}") }
				specify { expect(response.body).to match("#{m2.content}") }
				specify { expect(response.body).to match("#{user.name}") }
				specify { expect(response.body).not_to match("#{another_user.name}") }
			end

			describe "with proper authorization to view another users microposts" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, page: 1, format: :json }
					post "api/users/#{another_user.id}/microposts", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('content') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match('user') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('user_id') }
				specify { expect(response.body).to match("#{m3.content}") }
				specify { expect(response.body).to match("#{m4.content}") }
				specify { expect(response.body).not_to match("#{user.name}") }
				specify { expect(response.body).to match("#{another_user.name}") }
			end
		end


		describe "accessing follow action" do
			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/users/#{another_user.id}/follow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/#{another_user.id}/follow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/#{another_user.id}/follow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with invalid user_id" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/123456789/follow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid user_id, operation failed') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{another_user.id}/follow", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{another_user.name}") }
				specify { expect(response.body).not_to match("#{another_user.email}") }
			end
		end


		describe "accessing unfollow action" do
			before do
				user.save
				another_user.save
				user.follow!(another_user)
			end

			describe "without proper authorization" do
				before do
					params = { format: :json }
					post "api/users/#{another_user.id}/unfollow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/#{another_user.id}/unfollow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/#{another_user.id}/unfollow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with invalid user_id" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/123456789/unfollow", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid user_id, operation failed') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/#{another_user.id}/unfollow", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).to match("#{another_user.name}") }
				specify { expect(response.body).not_to match("#{another_user.email}") }
			end
		end

		describe "accessing autofriend_all_users action" do
			let(:other_user_1) { FactoryGirl.create(:user) }
			let(:other_user_2) { FactoryGirl.create(:user) }
			let(:other_user_3) { FactoryGirl.create(:user) }
			let(:other_user_4) { FactoryGirl.create(:user) }

			before do
				other_user_1.save
				other_user_2.save
				other_user_3.save
				other_user_4.save
			end

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/autofriend_all_users", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/autofriend_all_users", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/autofriend_all_users", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization to autofriend all users" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/autofriend_all_users", params
				end

				specify { response.should be_success }
				specify { expect(response.body).to match('friendships') }
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('user_id') }
				specify { expect(response.body).to match('friend_id') }
				specify { expect(response.body).to match('status') }
				specify { expect(response.body).to match('accepted') }
				specify { expect(response.body).to match('created_at') }
				specify { expect(response.body).to match('updated_at') }
				specify { expect(response.body).to match("#{user.id}") }
				specify { expect(response.body).to match("#{other_user_1.id}") }
				specify { expect(response.body).to match("#{other_user_2.id}") }
				specify { expect(response.body).to match("#{other_user_3.id}") }
				specify { expect(response.body).to match("#{other_user_4.id}") }

				specify { expect(user.friends).to include(other_user_1) }
				specify { expect(user.friends).to include(other_user_2) }
				specify { expect(user.friends).to include(other_user_3) }
				specify { expect(user.friends).to include(other_user_4) }

				specify { expect(other_user_1.friends).to include(user) }
				specify { expect(other_user_2.friends).to include(user) }
				specify { expect(other_user_3.friends).to include(user) }
				specify { expect(other_user_4.friends).to include(user) }
			end
		end

		describe "accessing friends action" do
			let(:friend1) { FactoryGirl.create(:user) }
			let(:friend2) { FactoryGirl.create(:user) }
			let(:friend3) { FactoryGirl.create(:user) }
			let(:enemy1) { FactoryGirl.create(:user) }
			let(:enemy2) { FactoryGirl.create(:user) }

			before do
				friend1.save
				friend2.save
				friend3.save
				enemy1.save
				enemy2.save

				user.friend!(friend1)
				user.friend!(friend2)
				user.friend!(friend3)
			end

			describe "without proper authorization" do
				before do
					params = { page: 1, format: :json }
					post "api/users/friends", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: missing session parameters') }			
			end

			describe "with an unregistered device" do
				before do
					params = { udid: "unregistered_device_udid", remember_token: "random_token" }
					post "api/users/friends", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('forbidden: unregistered device, access denied') }
			end

			describe "with a device the user does not own" do
				before do
					unowned_device = FactoryGirl.create(:device)
					params = { udid: unowned_device.udid, remember_token: "random_token" }
					post "api/users/friends", params
				end
				specify { response.should_not be_success}
				specify { expect(response.body).to match('error') }	
				specify { expect(response.body).to match('invalid session, access denied') }
			end

			describe "with proper authorization" do
				before do
					params = { udid: device.udid, remember_token: ownership.remember_token, format: :json }
					post "api/users/friends", params
				end
				specify { response.should be_success }
				specify { expect(response.body).to match('success') }	
				specify { expect(response.body).to match('id') }
				specify { expect(response.body).to match('name') }
				specify { expect(response.body).not_to match('email') }
				specify { expect(response.body).not_to match('password_digest') }
				specify { expect(response.body).not_to match('remember_token') }
				specify { expect(response.body).to match("#{friend1.id}") }
				specify { expect(response.body).to match("#{friend2.id}") }
				specify { expect(response.body).to match("#{friend3.id}") }
				specify { expect(response.body).to match("#{friend1.name}") }
				specify { expect(response.body).to match("#{friend2.name}") }
				specify { expect(response.body).to match("#{friend3.name}") }
				specify { expect(response.body).to match("#{friend1.username}") }
				specify { expect(response.body).to match("#{friend2.username}") }
				specify { expect(response.body).to match("#{friend3.username}") }
				specify { expect(response.body).not_to match("#{friend1.email}") }
				specify { expect(response.body).not_to match("#{friend2.email}") }
				specify { expect(response.body).not_to match("#{friend3.email}") }
				specify { expect(response.body).not_to match("#{friend1.password_digest}") }
				specify { expect(response.body).not_to match("#{friend2.password_digest}") }
				specify { expect(response.body).not_to match("#{friend3.password_digest}") }
				specify { expect(response.body).not_to match("#{friend1.remember_token}") }
				specify { expect(response.body).not_to match("#{friend2.remember_token}") }
				specify { expect(response.body).not_to match("#{friend3.remember_token}") }
				specify { expect(response.body).not_to match("#{enemy1.id}") }
				specify { expect(response.body).not_to match("#{enemy2.id}") }
				specify { expect(response.body).not_to match("#{enemy1.name}") }
				specify { expect(response.body).not_to match("#{enemy2.name}") }
				specify { expect(response.body).not_to match("#{enemy1.username}") }
				specify { expect(response.body).not_to match("#{enemy2.username}") }
			end
		end
	end

end