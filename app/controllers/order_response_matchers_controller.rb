class OrderResponseMatchersController < ResponseMatchersController
  protected
    def matcher_params
      params.require(:order_response_matcher).permit(:question_id, :segment_id, :type, :inclusion, :first_place_choice_id)
    end
end