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

  validates :display_name, presence: true
  #validates :klass, presence: true, inclusion: { in: Sticker::TYPES }

  # Modify the updated time of the studios on save so app knows the sticker packs need to be re-loaded
  before_save do
    studios.each do |studio|
      studio.touch
      studio.save
    end
  end

  def available_stickers
    Rails.cache.fetch("#{Rails.env}:#{self.id}:stickers".hash.to_s, expires_in: sticker_ttl) do
      available_stickers = stickers.where.not(type: 'Background')
    end
  end

  def backgrounds
    Rails.cache.fetch("#{Rails.env}:#{self.id}:backgrounds".hash.to_s, expires_in: sticker_ttl) do
      backgrounds = stickers.where(type: 'Background')
    end
  end

  def header_icon_thumb_url
    header_icon.thumb.url
  end

  def api_response(options={})
    response = {:id => self.id, :display_name => self.display_name, :header_icon_url => self.header_icon_url,
     :updated_at => self.updated_at}
    if options['sort_order']
      response['sort_order'] = options['sort_order']
    end
    response
  end

  private
    def sticker_ttl
      @sticker_ttl ||= ENV['STICKER_CACHE_TTL_IN_MINUTES'] ? ENV['STICKER_CACHE_TTL_IN_MINUTES'].to_i.minutes : 1.minute
    end
end
