class TextResponseMatchersController < ResponseMatchersController
  protected
    def matcher_params
      params.require(:text_response_matcher).permit(:question_id, :segment_id, :type, :inclusion, :regex)
    end
end