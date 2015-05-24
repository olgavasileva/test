class Target < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :questions

  def apply_to_question! question, options = {}
    options.reverse_merge background: :auto

    question.targeting! self

    if should_perform_in_background? options[:background]
      Resque.enqueue(ApplyTargetingToQuestion, question.id, id)
    else
      apply_in_foreground! question
    end
  end

  def public?
    targeting_all_users?
  end

  protected
    # override in subclass if not always false
    def targeting_all_users?
      false
    end

    def apply! question
      # subclass should override
    end

    def target_respondents! question, respondents
      items = []

      respondents.find_in_batches do |respondents|
        respondents.each do |respondent|
          unless respondent.question_targets.exists?(question_id: question.id)
            items << QuestionTarget.new(target_id: id, question_id: question.id, respondent_id: respondent.id, relevance: question.relevance_to(respondent))
          end
        end
      end

      # Batch import
      QuestionTarget.import items

      # Push notification for targeted questions
      respondents.find_each {|respondent| question.add_and_push_message respondent}
    end

  private
    def should_perform_in_background? in_background
      if in_background == :auto
        targeting_all_users?
      else
        in_background
      end
    end

    def apply_in_foreground! question
      apply! question
      question.activate!
    end

end
