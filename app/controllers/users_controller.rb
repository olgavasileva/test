class UsersController < ApplicationController
	before_action :signed_in_user,		only: [:index, :edit, :update, :destroy]
	before_action :correct_user,		only: [:edit, :update]
	before_action :admin_user,			only: :destroy
	before_action :not_signed_in_user,	only: [:new, :create]

	def index
		@users = User.paginate(page: params[:page])
	end

	def show
		@user = User.find(params[:id])
		@microposts = @user.microposts.paginate(page: params[:page])
		@questions = Question.where("questions.id IN (?)", Answer.select("question_id").where(user_id: @user.id))
	end

	def new
		@user = User.new
	end

	def create
	    @user = User.new(user_params)
	    if @user.save
	    	sign_in @user
	    	flash[:success] = "Welcome to the 2cents App!"
			redirect_to @user
	    else
			render 'new'
	    end
	end

	def edit
	end

	def update
	    if @user.update_attributes(user_params)
	      flash[:success] = "Profile updated"
	      redirect_to @user
	    else
	      render 'edit'
	    end
	end

	def destroy
		@user = User.find(params[:id])
		if current_user?(@user)
			redirect_to root_url
		else
			@user.destroy
			flash[:success] = "User destroyed."
			redirect_to users_url
		end
	end

	def following
		if signed_in?
			@title = "Following"
			@user = User.find(params[:id])
			@users = @user.followed_users.paginate(page: params[:page])
			render 'show_follow'
		else
			redirect_to signin_path
		end
	end

	def followers
		if signed_in?
			@title = "Followers"
			@user = User.find(params[:id])
			@users = @user.followers.paginate(page: params[:page])
			render 'show_follow'
		else
			redirect_to signin_path
		end
	end

	private

	    def user_params
	      params.require(:user).permit(:username, :name, :email, :password, :password_confirmation)
	    end

	    # Before filters

	    def correct_user
	    	@user = User.find(params[:id])
	    	redirect_to(root_url) unless current_user?(@user)
	    end

	    def admin_user
	    	redirect_to(root_url) unless current_user.admin?
	    end

	    def not_signed_in_user
	    	unless !signed_in?
	    		redirect_to root_url
	    	end
	    end
end
