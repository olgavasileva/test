module FormHelper
  def setup_response response
    if response.kind_of? OrderResponse
      response.question.choices.each do |choice|
        response.choice_responses.build choice:choice
      end
    end

    response
  end
end