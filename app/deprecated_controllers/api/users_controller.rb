class API::UsersController < ApplicationController
	skip_before_action :verify_authenticity_token
	#before_action :valid_remember_token, only: [:index, :following, :followers, :devices, :microposts, :follow, :unfollow]
	before_action :valid_remember_token, :except => [:create, :register, :login]

	def create
		if check_create_params
			@user = User.new(user_params)
			if @user.save
				render :json => { :success => @user }, :status => 200
			else
				render :json => { :error => @user.errors }, :status => 400
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def register
		if check_register_params
			@user = User.new(user_params)
			if @user.save
				@device = Device.find_by(udid: params[:device][:udid])
				if @device
					# device already exists in database
					@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
					if !@ownership
						@user.own!(@device)
						@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
					end
					render :json => { :success => @ownership }, :status => 200
				else
					# device does not exist in database
					@device = Device.new(device_params)
					if @device.save
						# device creation success
						@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
						if !@ownership
							@user.own!(@device)
							@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
						end
						render :json => { :success => @ownership }, :status => 200
					else
						# device creation failed
						render :json => { :error => "internal-server-error: device creation failed" }, :status => 500
					end
				end
			else
				render :json => { :error => @user.errors }, :status => 400
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def login
		if check_login_params
			@device = Device.find_by(udid: params[:device][:udid])
			if @device
				# device already exists in database
				login_ownership_helper
			else
				# device does not exist in database
				@device = Device.new(device_params)
				if @device.save
					# device creation success
					login_ownership_helper
				else
					# device creation failed
					render :json => { :error => "internal-server-error: device creation failed" }, :status => 500
				end
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def list_index
		if check_list_index_params
			@users = User.paginate(page: params[:page])
			render :json => { :success => @users }, :status => 200
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def following
		if check_following_params
			@user = User.find_by(id: params[:id])
			@users = @user.followed_users.paginate(page: params[:page])
			render :json => { :success => @users }, :status => 200
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def followers
		if check_followers_params
			@user = User.find_by(id: params[:id])
			@users = @user.followers.paginate(page: params[:page])
			render :json => { :success => @users }, :status => 200
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def devices
		if check_devices_params
			@user = User.find_by(id: params[:id])
			if @user == @current_user
				@devices = @user.devices.paginate(page: params[:page])
				render :json => { :success => @devices }, :status => 200
			else
				render :json => { :error => "forbidden: user can only access its own devices, access denied" }.to_json, :status => 403
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def microposts
		if check_microposts_params
			@user = User.find_by(id: params[:id])
			@microposts = @user.microposts.paginate(page: params[:page])
			render :json => { :success => @microposts }, :status => 200
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def follow
		@user = User.find_by(id: params[:id])
		if @user
			@current_user.follow!(@user)
			if @current_user.following?(@user)
				render :json => { :success => @user }, :status => 200
			else
				render :json => { :error => "internal-server-error: user follow failed" }, :status => 500
			end
		else
			render :json => { :error => "invalid user_id, operation failed" }, :status => 400
		end
	end

	def unfollow
		@user = User.find_by(id: params[:id])
		if @user
			@current_user.unfollow!(@user)
			if @current_user.following?(@user)
				render :json => { :error => "internal-server-error: user unfollow failed" }, :status => 500
			else
				render :json => { :success => @user }, :status => 200
			end
		else
			render :json => { :error => "invalid user_id, operation failed" }, :status => 400
		end
	end

	def autofriend_all_users
		users = User.all
		users.each do |user|
			unless user == @current_user
				unless @current_user.friends_with?(user)
					@current_user.friend!(user)
				end

				unless user.friends_with?(@current_user)
					user.friend!(@current_user)
				end
			end
		end

		@friendships = @current_user.friendships
		render :json => { :success => { :friendships => @friendships } }, :status => 200
	end

	def friends
		# no params to check, not doing paging with auto-friends
		@friends = @current_user.friends
		render :json => { :success => { :friends => @friends } }, :status => 200
	end


	private

		def valid_remember_token
			if params[:udid] && params[:remember_token]
				device = Device.find_by(udid: params[:udid])
				if device
					ownership = Ownership.find_by(device_id: device.id, remember_token: params[:remember_token])
					if ownership
						@current_user = User.find_by(id: ownership.user_id)
					else
						render :json => { :error => "forbidden: invalid session, access denied" }.to_json, :status => 403
					end
				else
					render :json => { :error => "forbidden: unregistered device, access denied" }.to_json, :status => 403
				end
			else
				render :json => { :error => "forbidden: missing session parameters, access denied" }.to_json, :status => 403
			end
		end

		def user_params
      params.require(:user).permit(:username, :name, :email, :password, :password_confirmation)
    end

    def device_params
			params.require(:device).permit(:udid, :device_type, :os_version)
		end

    def check_create_params
    	params[:user] && params[:user][:username] && params[:user][:name] && params[:user][:email] && params[:user][:password] && params[:user][:password_confirmation]
    end

    def check_register_params
			params[:user] && params[:user][:username] && params[:user][:name] && params[:user][:email] && params[:user][:password] && params[:user][:password_confirmation] && params[:device] && params[:device][:udid] && params[:device][:device_type] && params[:device][:os_version]
    end

    def check_login_params
    	params[:user] && params[:user][:username] && params[:user][:password] && params[:device] && params[:device][:udid] && params[:device][:device_type] && params[:device][:os_version]
    end

		def check_list_index_params
			params[:page]
		end

		def check_following_params
			params[:page]
		end

		def check_followers_params
			params[:page]
		end

		def check_devices_params
			params[:page]
		end

		def check_microposts_params
			params[:page]
		end

		def login_ownership_helper
			@user = User.find_by(username: params[:user][:username].downcase)
			if @user && @user.authenticate(params[:user][:password])
				@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
				if !@ownership
					@user.own!(@device)
					@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
				else
					remember_token = User.new_remember_token
					@ownership.update_attribute(:remember_token, User.encrypt(remember_token))
				end
				render :json => { :success => @ownership }, :status => 200
			else
				render :json => { :error => "forbidden: invalid username and password combination, access denied" }, :status => 403
			end
		end

end