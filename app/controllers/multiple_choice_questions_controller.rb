class MultipleChoiceQuestionsController < ApplicationController
  def new
    @question = MultipleChoiceQuestion.new user:current_user
    authorize @question
  end

  def update
  end
end
