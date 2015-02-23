class DataProvider < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  acts_as_list column: :priority
end
