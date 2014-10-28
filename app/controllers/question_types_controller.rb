class QuestionTypesController < ApplicationController
  def index
    authorize(QuestionType)
    @question_types = policy_scope(QuestionType)
  end
end