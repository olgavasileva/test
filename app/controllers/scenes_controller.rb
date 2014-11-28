class ScenesController < ApplicationController
  before_action :find_user

  def index
    policy_scope Scene    # Not sure how to utilize Pundit here, so just satisfying it's requirement that we use the policy_scope, but figuring out our own scene list
    @scenes = @user.scenes
  end

  def new
    studio = params[:studio_id].present? && Studio.find(params[:studio_id])
    @scene = Scene.new user:@user, studio:studio
    authorize @scene

    if studio.nil?
      flash[:alert] = "Please supply a scene"
      redirect_to :back
    end
  end

  def create
    @scene = Scene.new scene_params

    authorize @scene

    if !@scene.save
      flash[:alert] = @scene.errors.full_messages.join ", "
      render "new"
    else
      flash[:notice] = "You scene has been saved.  Thank you!"
      redirect_to [@user, :scenes]
    end
  end

  private
    def find_user
      @user = User.find params[:user_id]
    end

    def scene_params
      params.require(:scene).permit(:name, :user_id, :studio_id, :canvas_json, :base64_image)
    end
end