class ResponseMatcher < ActiveRecord::Base
  belongs_to :segment
  belongs_to :question

  INCLUSION_COLLECTION ||= [[:respond,"All people who responded to the question"], [:skip,"All people who skipped the question"], [:specific,"Only people who responded with:"]]

  validates :inclusion, inclusion:{ in: %W(skip respond specific) }

  def all_skippers?
    inclusion && inclusion.to_sym == :skip
  end

  def all_responders?
    inclusion && inclusion.to_sym == :respond
  end

  def specific_responders?
    inclusion && inclusion.to_sym == :specific
  end

  # Returns an AREL object
  def matched_users
    case inclusion
    when "skip"
      question.skip_users
    when "respond"
      question.response_users
    when "specific"
      matched_users_for_specific_response
    end
  end

  protected
    # Must return an AREL object
    def matched_users_for_specific_response
      if specific_responders?
        raise NotImplementedError.new("All subclasses must implement matched_users_for_specific_response.")
      end
    end
end
