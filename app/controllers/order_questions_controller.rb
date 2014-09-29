class OrderQuestionsController < QuestionsControllerBase
  protected
    def question_class
      OrderQuestion
    end

    def after_build_new question
      question.choices.build title:"Answer one"
      question.choices.build title:"Answer two"
    end

    def safe_params
      params.require(:order_question).permit(:type, :title, :category_id, choices_attributes:[:id, :title, :background_image_id])
    end
end
