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
    @target_count = @target.apply  # TODO - do this on a background resque queue or delayed job - it will take time when there are lots of users

    flash[:alert] = "Question added to #{view_context.pluralize @target_count, "user feed"}"
    redirect_to :root
  end

  protected
    def target_params
      params.require(:target).permit(:question_id, :all_users, :all_followers, :all_group_members)
    end
end