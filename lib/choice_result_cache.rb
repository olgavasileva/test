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
      unless response_count > 0
        # Any requested ratio would be 0.00 anyway
        return Hash.new { |h, k| h[k] = 0.00 }
      end

      remainder = 100
      results = {}

      data = question.choices.map do |choice|
        percent = (choice.responses.count * 100) / response_count.to_f
        whole = percent.to_i
        remainder -= whole
        {id: choice.id, decimals: percent % 1, whole: whole}
      end

      if remainder > 0
        data.sort! { |a, b| b[:decimals] <=> a[:decimals] }
      end

      data.each do |d|
        id, value = d[:id], d[:whole]

        if remainder > 0
          value += 1
          remainder -= 1
        end

        results[id] = (value.to_f / 100).round(2)
      end

      results
    end
  end

  def response_count
    @response_count ||= question.responses.count
  end
end
