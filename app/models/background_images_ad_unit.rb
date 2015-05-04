class BackgroundImagesAdUnit < ActiveRecord::Base
  belongs_to :background_image
  belongs_to :ad_unit

  serialize :meta_data

  attr_accessor :ad_unit_name
  before_validation :set_ad_unit_from_name
  validate :ad_unit_exists?, :background_image_exists?
  validate :meta_data_is_valid?
  validates :ad_unit_id, presence: true, uniqueness: { scope: :background_image_id }

  def update_from_image_meta_data(unit_name, value)
    self.ad_unit_name = unit_name
    self.meta_data = value
  end

  def update_from_image_meta_data!(unit_name, value)
    self.update_from_image_meta_data(unit_name, value)
    self.save!
  end

  private

  def set_ad_unit_from_name
    if !ad_unit.present? && ad_unit_name.present?
      self.ad_unit = AdUnit.find_by(name: ad_unit_name)
    end
  end

  def ad_unit_exists?
    unless ad_unit.present?
      errors.add(:ad_unit, :must_exist)
    end
  end

  def background_image_exists?
    unless background_image.present?
      errors.add(:background_image, :must_exist)
    end
  end

  def meta_data_is_valid?
    if !meta_data.present?
      errors.add(:meta_data, 'must contain some data')
    elsif !meta_data.is_a?(Hash)
      errors.add(:meta_data, 'must be a hash')
    end
  end
end
