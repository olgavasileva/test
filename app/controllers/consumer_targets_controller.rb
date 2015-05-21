class ConsumerTargetsController < ApplicationController
  def new
    @question = Question.find params[:question_id]
    @target = current_user.consumer_targets.build
    @followers = current_user.followers
    @groups = current_user.groups
    authorize @target
  end

  def create
    question = Question.find params.fetch(:question_id)
    target = question.build_target target_params
    authorize question.target

    target.save!
    target.apply_to_question! question

    question.update_attributes(anonymous: params.fetch(:anonymous))

    flash[:alert] = target.public? ? "Question added to the public feed" : "Question will be added to the targeted feeds"
    redirect_to results_question_path(question)
  end

  protected
    def target_params
      params.require(:consumer_target).permit(
        :question_id, :all_users, :all_followers, :all_groups, :user_id,
        follower_ids: [], group_ids: [])
    end
end
