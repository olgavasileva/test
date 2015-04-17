class Trend < ActiveRecord::Base
  FILTER_N ||= 8.0
  DEFAULT_NOISE_THRESHOLD = 3
  MIN_RATE_FOR_CALCULATION ||= 0.5

  default rate: 0.0

  default :calculated_at do |t|
    Time.current
  end
  default new_event_count: 0
  default filter_event_count: 0.0
  default filter_minutes: 0.0

  def self.calculate!
    # Only calculate trending for quesitons whose trending index is over a certain threshhold (i.e. not degraded super low)
    # OR have any responses since last time we calculated this.
    Trend.where("rate >= ?", MIN_RATE_FOR_CALCULATION).where.not(new_event_count: 0).find_each do |trend|
      trend.calculate!
    end
  end

  def event!
    increment! :new_event_count
  end

  def calculate!
    calculated = false
    threshold = Setting.fetch_value('view_noise_threshold')
    threshold ||= DEFAULT_NOISE_THRESHOLD

    unless new_event_count < threshold
      filterCoefficient = 1 - 1 / FILTER_N
      self.filter_minutes = filter_minutes * filterCoefficient + minutes_since_last_calculation
      self.filter_event_count = filter_event_count * filterCoefficient + new_event_count

      self.calculated_at = Time.current
      self.new_event_count = 0

      calculated = true
    end

    self.filter_minutes = 1 if filter_minutes == 0
    self.rate = filter_event_count / filter_minutes

    save!

    calculated
  end

  def minutes_since_last_calculation
    (Time.current - calculated_at) / 60.0
  end
end
