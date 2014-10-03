class ResponseMatcher < ActiveRecord::Base
  belongs_to :segment
  belongs_to :question

  INCLUSION_COLLECTION ||= [[:skip,"All people who skipped the question"],[:respond,"All people who responded to the question"], [:specific,"Only people who responded with:"]]

  def all_skippers?
    inclusion.to_sym == :skip
  end

  def all_responders?
    inclusion.to_sym == :respond
  end

  def specific_responders?
    inclusion.to_sym == :specific
  end
end
