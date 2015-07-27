class Listical < ActiveRecord::Base

  validates_presence_of :title

  belongs_to :user

  has_many :questions, class_name: 'ListicalQuestion'

  accepts_nested_attributes_for :questions, allow_destroy: true

end
