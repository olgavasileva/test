class ContestsController < ApplicationController
  before_action :maintain_vote_info, only: :save_vote

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

    vote_id = @contest.vote_id_for_response response

    if recently_voted_for? vote_id
      @notice = "You have already voted for that item today."
    else
      @contest.vote_for_response! response

      add_to_vote_info vote_id
      @notice = "Vote Recorded"
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def maintain_vote_info
      session[:vote_info] ||= {}

      # expire old vote info
      session[:vote_info].each do |vote_id, info|
        session[:vote_info].delete vote_id if info[:expires_at] < Time.current
      end
    end

    def add_to_vote_info vote_id, expires_in = 24.hours
      session[:vote_info][vote_id] = { expires_at: Time.current + expires_in }
    end

    def recently_voted_for? vote_id
      session[:vote_info].keys.include? vote_id
    end
end