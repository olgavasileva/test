class QuestionChoiceOrderer < Struct.new(:question, :reader)
  include Enumerable

  def each(&block)
    question_choices.each(&block)
  end

  def question_choices
    @question_choices ||= randomize_question_choices
  end

  def randomize_question_choices
    choices, choices_with_positions = choice_query.partition do |choice|
      !choice.position.present?
    end

    if question.rotate?
      choices = choices.shuffle(random: reader_seed)
    end

    choices_with_positions.each do |choice|
      choices.insert(choice.position, choice)
    end

    choices
  end

  def choice_query
    question.choices.order(position: :asc)
  end

  def reader_seed
    reader.try(:id).present? && Random.new(reader.id)
  end
end
