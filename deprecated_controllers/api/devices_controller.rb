class API::DevicesController < ApplicationController

	skip_before_action :verify_authenticity_token

	def create
		if check_create_params
			#params: email, password, udid, device_type, os_version all present
			@device = Device.find_by(udid: params[:session][:udid])
			if @device
				# device already exists in database
				ownership_creation_helper
			else
				# device does not exist in database
				@device = Device.new(device_params)
				if @device.save
					# device creation success
					ownership_creation_helper
				else
					# device creation failed
					render :json => { :error => "internal-server-error: device creation failed" }, :status => 500
				end
			end
		else
			# missing some required params for this method
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	private

		def device_params
			params.require(:session).permit(:udid, :device_type, :os_version)
		end

		def check_create_params
			params[:session] && params[:session][:udid] && params[:session][:device_type] && params[:session][:os_version] && params[:session][:email] && params[:session][:password]
		end

		def ownership_creation_helper
			@user = User.find_by(email: params[:session][:email].downcase)
			if @user && @user.authenticate(params[:session][:password])
				@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
				if !@ownership
					@user.own!(@device)
					@ownership = Ownership.find_by(device_id: @device.id, user_id: @user.id)
				end
				render :json => { :success => @ownership }, :status => 200
			else
				render :json => { :error => "forbidden: invalid email/password combination, access denied" }, :status => 403
			end
		end

end
