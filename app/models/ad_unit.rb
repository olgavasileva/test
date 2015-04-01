class AdUnit < ActiveRecord::Base
  has_many :background_images_ad_units, dependent: :delete_all
  has_many :background_images, through: :background_images_ad_units

  scope :by_name, ->(unit_name) { where(name: unit_name) }

  validates :name, uniqueness: true, presence: true
  validates :width, presence: true, numericality: { only_integer: true}
  validates :height, presence: true, numericality: { only_integer: true}
end
