class TargetsController < ApplicationController
  def new
    @question = Question.find params[:question_id]
    @target = current_user.targets.build
    @followers = current_user.followers
    @groups = current_user.groups
    authorize @target
  end

  def create
    question = Question.find params[:question_id]
    target = Target.new target_params
    authorize question.target

    target.save!
    target_count = question.apply_target! target  # TODO - do this on a background resque queue or delayed job - it will take time when there are lots of users
    reports = @target.public? ? ["the public feed"] : []
    reports << view_context.pluralize( target_count, "direct feed") if target_count > 0

    flash[:alert] = "Question added to #{ reports.join " and " }."
    redirect_to :root
  end

  protected
    def target_params
      params.require(:target).permit(:question_id, :all_users, :all_followers, :all_groups, :follower_ids, :group_ids)
    end
end