class SegmentsController < ApplicationController
  layout "pixel_admin"

  before_action :find_user

  def index
    @segments = policy_scope(Segment)
  end

  def new
    @segment = @user.segments.build
    authorize @segment
  end

  def create
    @segment = @user.segments.build segment_params
    authorize @segment

    if @segment.save
      flash[:alert] = "Segment created."
      redirect_to :index
    else
      flash[:error] = @segment.errors.full_messages.join ", "
      render "new"
    end
  end

  def edit
    @segment = @user.segments.find params[:id]
    authorize @segment
  end

  def update
    @segment = @user.segments.find params[:id]
    authorize @segment

    if @segment.update_attributes segment_params
      flash[:alert] = "Segment saved."
      redirect_to :index
    else
      flash[:error] = @segment.errors.full_messages.join ", "
      render "edit"
    end
  end

  def show
    @segment = @user.segments.find params[:id]
    authorize @segment
  end

  def destroy
    @segment = @user.segments.find params[:id]
    authorize @segment

    @segment.destroy!
    flash[:alert] = "Segment has been deleted."
    redirect_to :index
  end

  private
    def find_user
      @user = User.find_by params[:user_id]
    end

    def segment_params
      params.require(:segment).permit(:user_id, :name)
    end
end
