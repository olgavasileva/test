class API::SessionsController < ApplicationController

	include API::SessionsHelper

	skip_before_action :verify_authenticity_token

	def create
		if check_create_params
			# params: email, password, udid all present
			user = User.find_by(email: params[:session][:email].downcase)
	    if user && user.authenticate(params[:session][:password])
	    	# user exists and is authenticated
	      device = Device.find_by(udid: params[:session][:udid])
	      if device
	      	# device exists
	      	ownership = Ownership.find_by(device_id: device.id, user_id: user.id)
	      	if ownership
	      		# user owns device
	      		sign_in(user, device)
	      		ownership = Ownership.find_by(device_id: device.id, user_id: user.id)
	      		render :json => { :success => ownership }, :status => 200
	      	else
	      		# user does not own this device
	      		render :json => { :error => "forbidden: user does not own this device, access denied" }, :status => 403
	      	end
	      else
	      	# device does not exist in database
	      	render :json => { :error => "forbidden: unregistered device, access denied" }, :status => 403
	      end
	    else
	    	# incorrect username / password combination for user
	      render :json => { :error => "forbidden: invalid email/password combination, access denied" }, :status => 403
	    end
		else
			# missing some required params for this method
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	private

		def check_create_params
			params[:session] && params[:session][:udid] && params[:session][:email] && params[:session][:password]
		end
end
