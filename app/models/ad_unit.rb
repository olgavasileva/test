class AdUnit < ActiveRecord::Base
  has_many :background_images_ad_units
  has_many :background_images, through: :background_images_ad_units

  validates :name, uniqueness: true, presence: true
  validates :width, presence: true, numericality: { only_integer: true}
  validates :height, presence: true, numericality: { only_integer: true}
end
