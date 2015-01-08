class StickerPack < ActiveRecord::Base
  include Togglable
  include Expirable

  just_define_datetime_picker :starts_at
  just_define_datetime_picker :expires_at

  mount_uploader :header_icon, ImageUploader
  mount_uploader :footer_image, ImageUploader

  has_many :studios

  has_many :sticker_pack_stickers, -> {order(:sort_order)}
  has_many :stickers, through: :sticker_pack_stickers

  scope :enabled, -> { where.not disabled: true }

  # Modify the updated time of the studios on save so app knows the sticker packs need to be re-loaded
  before_save :touch_studios
  before_validation :ensure_disabled_set

  validates :display_name, presence: true
  validates :disabled, inclusion: {in:[true, false]}


  def enabled_stickers
    # Rails.cache.fetch("#{Rails.env}:#{self.id}:stickers".hash.to_s, expires_in: sticker_ttl) do
      enabled_stickers = stickers.enabled.where.not(type: 'Background')
    # end
  end

  def enabled_backgrounds
    # Rails.cache.fetch("#{Rails.env}:#{self.id}:backgrounds".hash.to_s, expires_in: sticker_ttl) do
      backgrounds = stickers.enabled.where(type: 'Background')
    # end
  end

  def header_icon_thumb_url
    header_icon.thumb.url
  end

  private
    def sticker_ttl
      @sticker_ttl ||= ENV['STICKER_CACHE_TTL_IN_MINUTES'] ? ENV['STICKER_CACHE_TTL_IN_MINUTES'].to_i.minutes : 1.minute
    end

    def ensure_disabled_set
      self.disabled = false if disabled.nil?
      true
    end

    def touch_studios
      studios.each{|s| s.touch}
      true
    end
end
