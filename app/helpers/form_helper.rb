module FormHelper
  def setup_response response
    if response.kind_of? OrderResponse
      response.question.choices.each do |choice|
        response.choice_responses.build choice:choice
      end
    elsif response.kind_of? StudioResponse
      response.build_scene user:current_user, studio:response.question.studio
    end

    response
  end

  def setup_response_matcher matcher
    matcher
  end
end