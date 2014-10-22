class Setting < ActiveRecord::Base
  default enabled: true

  scope :enabled, -> { where enabled:true }
end
