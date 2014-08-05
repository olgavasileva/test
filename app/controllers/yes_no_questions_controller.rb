class YesNoQuestionsController < ApplicationController
  def new
    @question = YesNoQuestion.new user:current_user
    authorize @question
  end

  def update
  end
end