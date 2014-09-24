class ChoiceResponseMatchersController < ResponseMatchersController
  protected
    def matcher_params
      params.require(:choice_response_matcher).permit(:question_id, :segment_id, :type, :choice_id)
    end
end