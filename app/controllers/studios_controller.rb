class StudiosController < ApplicationController
  before_action :find_user

  def show
    @studio = Studio.find params[:id]
    authorize @studio

    @scenes = @studio.scenes.where(user:@user)
  end

  private
    def find_user
      @user = User.find params[:user_id]
    end
end