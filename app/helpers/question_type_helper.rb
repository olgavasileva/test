module QuestionTypeHelper
  def icon_for question_type
    case true
    when question_type.type == YesNoQuestion
      "icons/YesNo.png"
    when question_type.type == TextChoiceQuestion
      "icons/MultipleChoice.png"
    when question_type.type == ImageChoiceQuestion
      "icons/SingleSelect.png"
    when question_type.type == MultipleChoiceQuestion
      "icons/MultiSelect.png"
    when question_type.type == TextQuestion
      "icons/OpenEnded.png"
    when question_type.type == OrderQuestion
      "icons/Prioritizer.png"
    end
  end

  def title_for question_type
    case true
    when question_type.type == YesNoQuestion
      "Yes/No"
    when question_type.type == TextChoiceQuestion
      "Multiple Choice"
    when question_type.type == ImageChoiceQuestion
      "Pick One"
    when question_type.type == MultipleChoiceQuestion
      "Pick Two"
    when question_type.type == TextQuestion
      "Open Ended"
    when question_type.type == OrderQuestion
      "Prioritizer"
    end
  end

  def path_for_new question_type
    case true
    when question_type.type == YesNoQuestion
      new_yes_no_question_path
    when question_type.type == TextChoiceQuestion
      new_text_choice_question_path
    when question_type.type == ImageChoiceQuestion
      new_image_choice_question_path
    when question_type.type == MultipleChoiceQuestion
      new_multiple_choice_question_path
    when question_type.type == TextQuestion
      new_text_question_path
    when question_type.type == OrderQuestion
      new_order_question_path
    end
  end
end
