class AdUnit < ActiveRecord::Base
  has_many :background_images_ad_units, dependent: :delete_all
  has_many :background_images, through: :background_images_ad_units

  attr_accessor :json_meta_data
  serialize :default_meta_data

  scope :by_name, ->(unit_name) { where(name: unit_name) }

  before_validation :parse_json_meta_data, if: 'json_meta_data.present?'
  validates :name, uniqueness: true, presence: true
  validates :width, presence: true, numericality: { only_integer: true}
  validates :height, presence: true, numericality: { only_integer: true}

  private

  def parse_json_meta_data
    self.default_meta_data = JSON.parse(json_meta_data)
  rescue JSON::ParserError
    errors.add(:default_meta_data, 'could not be parsed')
  end
end
