class Studio < ActiveRecord::Base
  just_define_datetime_picker :starts_at
  just_define_datetime_picker :expires_at

  belongs_to :scene
  belongs_to :starting_sticker_pack, class_name: 'StickerPack'
  belongs_to :contest, -> {where(contest: true)}, class_name: 'GalleryTemplate'

  has_many :studio_sticker_packs, -> { order(:sort_order) }
  has_many :sticker_packs, through: :studio_sticker_packs
  has_many :stickers, through: :sticker_packs
  has_many :scenes, dependent: :destroy

  validates :name, uniqueness: true, presence: true
  validates :display_name, presence: true

  before_save :convert_markdown

  mount_uploader :image, ImageUploader
  mount_uploader :icon, StudioIconUploader

  scope :featured, -> {where(featured: true)}


  private
    def convert_markdown
      self.getting_started_html = RDiscount.new(getting_started_markdown, :filter_html).to_html unless getting_started_markdown.nil?
      self.help_html = RDiscount.new(help_markdown, :filter_html).to_html unless help_markdown.nil?
      self.stand_alone_studio_header_html = RDiscount.new(stand_alone_studio_header_markdown, :filter_html).to_html unless stand_alone_studio_header_markdown.nil?
    end
end
