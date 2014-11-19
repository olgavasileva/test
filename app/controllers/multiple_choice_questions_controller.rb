class MultipleChoiceQuestionsController < QuestionsControllerBase
  protected
    def question_class
      MultipleChoiceQuestion
    end

    def after_build_new question
      question.choices.build title:"Option one"
      question.choices.build title:"Option two"
    end

    def safe_params
      params.require(:multiple_choice_question).permit(:type, :title, :category_id, :rotate, :min_responses, :max_responses, choices_attributes:[:id, :title, :muex, :background_image_id, :rotate, :_destroy])
    end
end
