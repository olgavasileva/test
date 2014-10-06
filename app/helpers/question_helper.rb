module QuestionHelper

  def canned_question_images
    @canned_question_images ||= CannedQuestionImage.order(:position)
  end

  def canned_question_image_ids
     canned_question_images.pluck(:id)
  end

  def canned_question_image_web_urls
    canned_question_images.map{|i| i.web_image_url}
  end



  def canned_choice_images
    @canned_choice_images ||= CannedChoiceImage.order(:position)
  end

  def canned_choice_image_ids
     canned_choice_images.pluck(:id)
  end

  def canned_choice_image_web_urls
    canned_choice_images.map{|i| i.web_image_url}
  end



  def canned_order_choice_images
    @canned_order_choice_images ||= CannedOrderChoiceImage.order(:position)
  end

  def canned_order_choice_image_ids
     canned_order_choice_images.pluck(:id)
  end

  def canned_order_choice_image_web_urls
    canned_order_choice_images.map{|i| i.web_image_url}
  end

end