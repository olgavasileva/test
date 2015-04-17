class Setting < ActiveRecord::Base
  default enabled: true

  scope :enabled, -> { where enabled: true }

  def self.fetch_value(key)
    Setting.find_by(key: key).try(:value)
  end
end
