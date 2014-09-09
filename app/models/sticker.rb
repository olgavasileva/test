class Sticker < ActiveRecord::Base
  include Togglable

  TYPES ||= %w(Background Sticker)

  mount_uploader :image, StickerImageUploader, :mount_on => :image

  has_many :sticker_pack_stickers
  has_many :sticker_packs, through: :sticker_pack_stickers

  has_many :item_properties, as: :item

  accepts_nested_attributes_for :item_properties,
                                allow_destroy: true,
                                reject_if: -> (ip) { #Ignore the property if it already exists, instead of throwing an error
                                  ip[:key].blank? || ip[:value].blank? && ItemProperty.where(key: ip[:key], item_id: ip[:item_id], item_type: ip[:item_type]).empty?
                                }

  acts_as_taggable
  acts_as_taggable_on :categories

  validates :display_name, presence: true
  validates :priority, numericality: true
  validates :type, inclusion: {in: TYPES}

  before_create :set_priority_value
  before_save :set_image_geometry

  # Modify the updated time of the sticker packs on save so app knows the stickers need to be re-loaded
  after_save do
    sticker_packs.each do |sticker_pack|
      sticker_pack.touch
      sticker_pack.save
    end
  end

  scope :backgrounds, -> {where(type: 'Background')}
  scope :stickers, -> {where(type: 'Sticker')}

  def self.available
    active
  end

  def available?
    active && started && !expired && image.present?
  end

  def set_image_geometry(force=false)
    if image.present? && (image_changed? || force)
      geo = image.try(:geometry)
      self.image_height = geo.try(:[], :height)
      self.image_width = geo.try(:[], :width)
    end
  end

  def set_priority_value
    if self.priority.nil?
      # add it to the end if the admin hasn't set a priority
      self.priority = Sticker.maximum(:priority).to_i + 1
    end
  end
end