class StudioResponsesController < ResponsesController

  protected

    def response_params
      params.require(:studio_response).permit(:user_id, :question_id, :type, scene_attributes:[ :user_id, :studio_id, :canvas_json ], comment_attributes:[ :id, :body, :user_id, :commentable_id ])
    end
end
