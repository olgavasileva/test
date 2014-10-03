module Togglable
  extend ActiveSupport::Concern

  included do
    scope :disabled, -> {where(disabled: true)}

    scope :active, -> {
        if self.respond_to?(:not_expired) && self.respond_to?(:started)
          started.not_expired.where(disabled: false)
        else
          where(disabled: false)
        end
    }
  end

  def disable
    self.disabled= true
  end

  def activate
    self.disabled = false
  end

  def disable!
    update_attribute(:disabled, true)
  end

  def activate!
    update_attribute(:disabled, false)
  end

  def active
    !disabled
  end
  alias_method :active?, :active

  def delete
    self.disable
  end
end