class Message < ActiveRecord::Base
  belongs_to :user
  after_initialize :defaults

  def defaults
    self.read_at = Time.zone.now()
  end
end
