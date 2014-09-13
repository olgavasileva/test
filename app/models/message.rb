class Message < ActiveRecord::Base
  belongs_to :user
  before_create :defaults

  def defaults
    self.read_at = nil
  end
end