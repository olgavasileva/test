class Key < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  def to_s
    key
  end
end
