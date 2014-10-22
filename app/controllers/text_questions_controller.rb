class TextQuestionsController < QuestionsControllerBase
  protected
    def question_class
      TextQuestion
    end

    def after_build_new question
    end

    def safe_params
      params.require(:text_question).permit(:type, :title, :category_id, :background_image_id)
    end
end
