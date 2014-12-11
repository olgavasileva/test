class ResponseObserver < ActiveRecord::Observer
  def after_create response
    response.question.answered! response.user
  end
end