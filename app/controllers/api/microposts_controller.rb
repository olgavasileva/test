class API::MicropostsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :valid_remember_token
	before_action :correct_user,					only: :destroy

	def create
		if check_create_params
			@micropost = @current_user.microposts.build(micropost_params)
			if @micropost.save
				render :json => { :success => @micropost }, :status => 200
			else
				render :json => { :error => @micropost.errors }, :status => 400
			end
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
	end

	def destroy
		@micropost.destroy
		render :json => { :success => "micropost successfully destroyed" }, :status => 200
	end

	def user_feed
		if check_user_feed_params
			@microposts = @current_user.feed.paginate(page: params[:page])
			render :json => { :success => @microposts }, :status => 200
		else
			render :json => { :error => "incorrect params received" }, :status => 400
		end
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
						render :json => { :error => "forbidden: invalid session, access denied" }, :status => 403
					end
				else
					render :json => { :error => "forbidden: unregistered device, access denied" }, :status => 403
				end
			else
				render :json => { :error => "forbidden: missing session parameters, access denied" }, :status => 403
			end
		end

		def correct_user
			@micropost = @current_user.microposts.find_by(id: params[:id])
			render :json => { :error => "forbidden: user cannot delete another users micropost, access denied" }, :status => 403 if @micropost.nil?
		end

		def micropost_params
      params.require(:micropost).permit(:content)
    end

    def check_create_params
    	params[:micropost] && params[:micropost][:content]
    end

    def check_user_feed_params
    	params[:page]
    end

end