class Setting < ActiveRecord::Base
  default enabled: true

  scope :enabled, -> { where enabled: true }

  def self.fetch_values(*keys)
    settings = Hash[Setting.where(key: keys).pluck(:key, :value)]
    settings.with_indifferent_access
  end

  def self.fetch_value(key, default=nil)
    Setting.find_by(key: key).try(:value) || default
  end
end
