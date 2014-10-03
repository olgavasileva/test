class ImageChoiceQuestionsController < QuestionsControllerBase
  protected
    def question_class
      ImageChoiceQuestion
    end

    def after_build_new question
      question.choices.build title:"Option one"
      question.choices.build title:"Option two"
    end

    def safe_params
      params.require(:image_choice_question).permit(:type, :title, :category_id, :rotate, choices_attributes:[:id, :title, :background_image_id, :_destroy])
    end
end