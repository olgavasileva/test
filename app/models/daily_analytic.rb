class DailyAnalytic < ActiveRecord::Base
  def self.increment! metric, user
    analytic = DailyAnalytic.where(user_id:user, metric:metric, date:Date.today).first_or_create!
    analytic.update_attribute :total, analytic.total.to_i + 1
  end

  def self.fetch metric, date, user
    DailyAnalytic.where(user_id:user, metric:metric, date:date).first.try(:total).to_i
  end
end