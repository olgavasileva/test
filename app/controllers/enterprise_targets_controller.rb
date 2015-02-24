class EnterpriseTargetsController < ApplicationController
  layout "pixel_admin"

  def new
    @question = Question.find params.fetch(:question_id)
    @enterprise_target = current_user.enterprise_targets.build(gender: 'both')
    authorize @enterprise_target
  end

  def create
    @question = Question.find params.fetch(:question_id)
    @enterprise_target = EnterpriseTarget.new enterprise_target_params
    authorize @enterprise_target

    if @enterprise_target.save
      @enterprise_target.apply_to_question @question

      # Done building the campaign so next time, they can target however is appropriate
      session.delete :use_enterprise_targeting

      flash[:alert] = "Question has been added to the desired feeds."
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
