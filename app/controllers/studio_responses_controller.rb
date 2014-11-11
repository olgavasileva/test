class StudioResponsesController < ResponsesController

  protected

    def response_params
      params.require(:studio_response).permit(:user_id, :question_id, :type, scene_attributes:[ :name, :user_id, :studio_id, :canvas_json, :base64_image ], comment_attributes:[ :id, :body, :user_id, :commentable_id ])
    end
end
