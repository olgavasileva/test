class CronTask

  class << self

    def perform method
      with_logging method do
        self.new.send method
      end
    end

    def with_logging method, &block
      log "starting...", method

      time = Benchmark.ms do
        yield block
      end

      log "completed in (%.1fms)" % [time], method
    end

    def log message, method = nil
      now = Time.now.strftime "%Y-%m-%d %H:%M:%S"
      puts "#{now} %s#%s - #{message}" % [self.name, method]
    end

  end

  def trending
    Trend.calculate!
  end

  def count_recent_responses
    Question.refresh_recent_responses_count! Setting.fetch_value('trend_lookback_days', 14).to_i
  end

  def purge_inactive_user_feed_items
    if Figaro.env.DAYS_CONSIDERED_INACTIVE && Figaro.env.QUESTIONS_TO_KEEP_WHEN_INACTIVE
      Respondent.inactive(Figaro.env.DAYS_CONSIDERED_INACTIVE.to_i).find_each do |respondent|
        begin
          respondent.purge_feed_items!(Figaro.env.QUESTIONS_TO_KEEP_WHEN_INACTIVE.to_i)
        rescue ActiveRecord::StatementInvalid => e
          CronTask.log "Skipping respondent #{respondent.id} due to exception:"
          CronTask.log e, 'purge_inactive_user_feed_items'
        end
      end
    end
  end

end