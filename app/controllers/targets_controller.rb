class TargetsController < ApplicationController
  def new
    @target = Target.new question_id:params[:question_id]
    authorize @target

    @followers = current_user.followers
    @groups = current_user.groups
  end

  def create
    @target =Target.new target_params
    authorize @target
    @target_count = @target.apply_to_user current_user  # TODO - do this on a background resque queue or delayed job - it will take time when there are lots of users
    @public = @target.public?
    targets = @target.public? ? ["the public feed"] : []
    targets << view_context.pluralize( @target_count, "direct feed") if @target_count > 0

    flash[:alert] = "Question added to #{ targets.join " and " }."
    redirect_to :root
  end

  protected
    def target_params
      params.require(:target).permit(:question_id, :all_users, :all_followers, :all_groups, :follower_ids, :group_ids)
    end
end