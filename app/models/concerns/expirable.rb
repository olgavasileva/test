module Expirable
  extend ActiveSupport::Concern

  included do
    scope :started, -> { where("(#{table_name}.starts_at <= ? OR #{table_name}.starts_at IS NULL)", Time.now.to_s(:mysql)) }

    scope :not_started, -> { where("(#{table_name}.starts_at >= ? OR #{table_name}.starts_at IS NOT NULL)", Time.now.to_s(:mysql)) }

    scope :expired, -> { where("(#{table_name}.expires_at <= ? AND #{table_name}.expires_at IS NOT NULL)", Time.now.to_s(:mysql)) }

    scope :not_expired, -> { where("(#{table_name}.expires_at >= ? OR #{table_name}.expires_at IS NULL)", Time.now.to_s(:mysql)) }
  end

  def started
    starts_at <= Time.now rescue true
  end
  alias_method :started?, :started

  def expired
    expires_at <= Time.now rescue false
  end
  alias_method :expired?, :expired
end