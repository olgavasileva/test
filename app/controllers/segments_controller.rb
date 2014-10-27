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
      redirect_to [@user, :segments]
    else
      flash[:error] = @segment.errors.full_messages.join ", "
      redirect_to [@user, :segments]
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
      @segments = policy_scope(Segment)
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
    @segments = policy_scope(Segment)
    flash[:alert] = "Segment has been deleted."
    redirect_to [@user, :segments] unless request.xhr?
  end

  def question_search
    @segment = @user.segments.find params[:id]
    authorize @segment

    search_term = params[:term]
    questions = Question.where("title like ?", "%#{search_term}%").select([:id, :title])
    response = questions.map{|q| {id:q.id, title:q.title, load_url:view_context.new_user_segment_response_matcher_url(@user, @segment, question_id:q)}}
    render json:response
  end

  private
    def find_user
      @user = User.find_by id:params[:user_id]
    end

    def segment_params
      params.require(:segment).permit(:user_id, :name)
    end
end
