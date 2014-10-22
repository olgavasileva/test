class EnterpriseTargetsController < ApplicationController
  layout "pixel_admin"

  def new
    @question = Question.find params.fetch(:question_id)
    @enterprise_target = current_user.enterprise_targets.build
    authorize @enterprise_target

    # Done building the campaign so next time, they can target however is appropriate
    session.delete :use_enterprise_targeting
  end

  def create
    @question = Question.find params.fetch(:question_id)
    @enterprise_target = EnterpriseTarget.new enterprise_target_params
    authorize @enterprise_target

    if @enterprise_target.save
      target_count = @enterprise_target.apply_to_question @question  # TODO - do this on a background resque queue or delayed job - it will take time when there are lots of users

      flash[:alert] = "Question added to #{ view_context.pluralize( target_count, "direct feed") }."
      redirect_to [:dashboard, current_user]
    else
      render "new"
    end
  end

  protected

    def enterprise_target_params
      params.require(:enterprise_target).permit(:question_id, :user_id, :min_age, :max_age, :gender)
    end
end