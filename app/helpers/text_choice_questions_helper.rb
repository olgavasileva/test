module TextChoiceQuestionsHelper

  def canned_question_image_urls
    @urls ||= Question::CANNED_IMAGE_PATHS
  end

end
