class QuestionType
  attr_accessor :type

  def self.all
    [
      QuestionType.new(YesNoQuestion),
      QuestionType.new(TextChoiceQuestion),
      QuestionType.new(ImageChoiceQuestion),
      QuestionType.new(MultipleChoiceQuestion),
      QuestionType.new(TextQuestion),
      QuestionType.new(OrderQuestion)
    ]
  end

  def initialize type
    @type = type
  end

  def to_s
    @type.name.underscore.humanize.titleize
  end
end