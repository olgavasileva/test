class BackgroundImage < ActiveRecord::Base

  has_many :questions
  has_many :choices
  has_many :ad_unit_infos,
    class_name: "BackgroundImagesAdUnit",
    dependent: :delete_all
  has_many :listical_questions

  attr_accessor :meta_data
  attr_accessor :meta_data_json
  attr_accessor :new_image_url

  before_validation :setup_image, if: 'new_image_url.present?'
  before_validation :convert_json, if: 'meta_data_json.present?'

  with_options if: 'meta_data.present?' do |meta|
    meta.validate :meta_data_is_valid_type?
    meta.validate :meta_data_has_valid_keys?
    meta.after_save :save_meta_data
  end

  def ad_unit_info(name)
    ad_unit_info_scope(name).first
  end

  def ad_unit_info_scope(name)
    ad_unit_infos.where.not(ad_unit_id: nil)
      .where(ad_unit_id: AdUnit.by_name(name).select(:id))
  end

  def web_image_url
    image.web.url
  end

  def device_image_url
    image.device.url
  end

  def retina_device_image_url
    image.retina_device.url
  end

  private

  def setup_image
    if URI(new_image_url).scheme.nil?
      self.image = open(new_image_url)
    else
      self.remote_image_url = new_image_url
    end
  end

  def convert_json
    meta_data_json.each do |key, value|
      if value.present?
        self.meta_data ||= {}
        self.meta_data[key] = begin
           JSON.parse(value)
        rescue JSON::ParserError => e
          errors.add(:base, "Invalid JSON for key #{key}: #{value}")
          nil
        end
      end
    end
  end

  def meta_data_is_valid_type?
    return unless errors[:base].empty?
    unless meta_data.is_a?(Hash) && meta_data.values.all? { |v| v.is_a?(Hash) && !v.empty? }
      errors.add(:base, 'Metadata must be a Hash of non-empty {key => Hash} pairs')
    end
  end

  def meta_data_has_valid_keys?
    return unless errors[:base].empty? && meta_data.is_a?(Hash)
    units = AdUnit.pluck(:name)
    invalid_keys = meta_data.keys.select { |k| !units.include?(k.to_s) }
    unless invalid_keys.empty?
      message = "Metadata contains invalid keys: #{invalid_keys.join(', ')}"
      errors.add(:base, message)
    end
  end

  def save_meta_data
    meta_data.each do |key, value|
      info = ad_unit_info_scope(key).first_or_initialize
      info.update_from_image_meta_data!(key, value)
    end
  end
end
