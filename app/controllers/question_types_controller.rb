class QuestionTypesController < ApplicationController
  def index
    @question_types = policy_scope(QuestionType)
  end
end