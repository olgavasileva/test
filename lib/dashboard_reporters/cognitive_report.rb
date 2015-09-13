class CognitiveReport < DashboardReport

  def get_report
    @report[:viral_factor] = viral_factor
    @report[:revisit_rate] = revisit_rate
  end

  private

  def viral_factor
    0 # not implemented
  end

  def revisit_rate
    0 # not implemented
  end

end