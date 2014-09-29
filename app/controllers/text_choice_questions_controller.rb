class TextChoiceQuestionsController < QuestionsControllerBase
  protected
    def question_class
      TextChoiceQuestion
    end

    def after_build_new question
      question.choices.build title:"Option one"
      question.choices.build title:"Option two"
    end

    def safe_params
      params.require(:text_choice_question).permit(:type, :title, :category_id, :background_image_id, :rotate, choices_attributes:[:id, :title, :_destroy])
    end
end
