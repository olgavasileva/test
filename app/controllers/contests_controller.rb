class ContestsController < ApplicationController
  def sign_up
    @contest = Contest.find_by uuid:params[:uuid]
    authorize @contest
    session[:contest_uuid] = @contest.uuid
    @user = User.new
  end

  def new_user
    @contest = Contest.find_by uuid:session[:contest_uuid]
    authorize @contest

    @user = User.new user_params
    if @user.save
      sign_in :user, @user if @user.save
      redirect_to new_question_response_path(question_id:@contest.questions.first.id) if @contest.questions.present?
    else
      render "sign_up"
    end
  end

  def vote
    @contest = Contest.find_by uuid:params[:uuid]
    authorize @contest

    if @contest.key_question.kind_of? StudioQuestion
      @studioResponses = @contest.key_question.responses
    else
      redirect_to :root
    end
  end

  def save_vote
    @contest = Contest.find_by uuid:params[:uuid]
    authorize @contest

    response = @contest.key_question.responses.find params[:response_id]
    @contest.vote_for_response! response
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
end