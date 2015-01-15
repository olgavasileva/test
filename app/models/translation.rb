class Translation < ActiveRecord::Base
  belongs_to :language

  validates :key, presence:true
  validates :value, presence:true
end
