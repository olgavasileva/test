class ChoiceResultCache < Struct.new(:question)

  def response_ratio_for(choice)
    choice_ratios[choice.id]
  end

  # Builds a result object for all choice responses at the same time
  # so that child records can access this data through the parent but
  # don't have to calculate it themselves.
  #
  def choice_ratios
    @choice_ratios ||= begin
      data = question.choices.map do |choice|
        percent = ((choice.responses.size * 100) / response_count.to_f)
        {id: choice.id, remainder: percent % 1, whole: percent.to_i}
      end

      total = data.inject(0) { |s, d| s + d[:whole] }
      remainder = 100 - total

      data.sort! { |a, b| a[:remainder] <=> a[:remainder] }
      results = {}

      data.each do |d|
        id, value = d[:id], d[:whole]
        value += 1 if remainder > 0
        remainder -= 1
        results[id] = (value.to_f / 100).round(2)
      end

      results
    end
  end

  def response_count
    @response_count ||= question.responses.size
  end
end
