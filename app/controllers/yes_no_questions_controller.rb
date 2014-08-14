class YesNoQuestionsController < QuestionsControllerBase
  protected
    def question_class
      YesNoQuestion
    end

    def after_build_new question
      question.choices.build title:"Yes"
      question.choices.build title:"No"
    end

    def safe_params
      params.require(:yes_no_question).permit(:type, :title, :category_id, :background_image_id, :rotate, choices_attributes:[:id, :title])
    end
end