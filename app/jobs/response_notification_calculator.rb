# Notifications are sent using the following algorithim
#
# Query:
#
#   The query loads all responses from the last 24 hours to questions created
#   by a single user, then groups them by question_id and returns an `Array`
#   representing the response count for each question.
#
# Numbers:
#
#   * `total_responses`: The sum of the array returned by the query
#   * `total_questions`: The length of the array returned by the query
#
# Multiples:
#
#   * `average`: `total_responses / total_questions`
#   * `median`: The median value of the array returned from the query
#   * `default`: Set by the client (see `ResponseNotificationCalculator::DEFAULT_MULTIPLE`)
#   * `expected`: The maximum of the above calculated values
#
# When do we send the notification?
#
#   We only notify the user if the total responses for the question passed to
#   this worker is a multiple of the `expected` value we calculated above.
#
class ResponseNotificationCalculator
  @queue = :notification

  DEFAULT_MULTIPLE = 25

  def self.perform(question_id)
    question = Question.eager_load(:user, :responses)
      .where(id: question_id, notifying: true).first

    # If the question doesn't exist, who cares
    self.new.perform(question) if question
  end

  def perform(question)
    multiple = calculate_multiple(question)
    responses = question.responses.size

    if multiple > 0 && responses > 0 && (responses % multiple) == 0
      Resque.enqueue(ResponseNotificationSender, question.id)
    end
  ensure
    # Always enable new notifications for this question to be processed
    question.update_attribute(:notifying, false) if question
  end

  # These methods are extracted to make testing easier

  def calculate_multiple(question)
    # A user defined multiple always overrides any one we might calculate
    if question.user.push_on_question_answered > -1
      return question.user.push_on_question_answered
    end

    responses = fetch_response_values(question.user)
    total_questions = responses.length
    total_responses = responses.inject(:+)

    average = calculate_average(total_questions, total_responses)
    median = calculate_median(responses)

    [average, median, DEFAULT_MULTIPLE].max
  rescue StandardError => exception
    Airbrake.notify_or_ignore(exception, question_id: question.id)
    0
  end

  def fetch_response_values(user, since=1.day.ago)
    Response.joins(question: [:user])
      .where('responses.created_at >= ?', since)
      .where(questions: {users: {id: user.id}})
      .group(:question_id)
      .count
      .values
  end

  def calculate_average(questions, responses)
    return 0 unless questions > 0 && responses > 0
    (responses / questions).to_i
  end

  def calculate_median(values)
    return 0 unless values.length > 0
    sorted = values.sort
    len = sorted.length
    ((sorted[(len - 1) / 2] + sorted[len / 2]) / 2).to_i
  end
end
