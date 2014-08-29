class UsersController < ApplicationController
  def profile
    @user = current_user
    authorize @user
  end

  def show
    @user = User.find params[:id]
    authorize @user
  end

  def follow
    @user = User.find params[:id]
    authorize @user

    current_user.follow! @user
  end
end