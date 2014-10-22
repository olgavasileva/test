class SkippedItemsController < ApplicationController
  def new
    question = Question.find params[:question_id]
    @skipped_item = question.skips.new user:current_user
    authorize @skipped_item

    if @skipped_item.save
      next_q = next_question question
      if next_q
        redirect_to new_question_response_path(next_q)
      else
        redirect_to :root
      end
    else
      flash[:error] = "Unable to skip the question"
      redirect_to new_question_response_path(question)
    end
  end
end