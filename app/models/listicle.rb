class Listicle < ActiveRecord::Base
  validates_presence_of :title

  belongs_to :user

  has_many :questions, class_name: 'ListicleQuestion', dependent: :destroy

  accepts_nested_attributes_for :questions, allow_destroy: true
end