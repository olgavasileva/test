class Studio < ActiveRecord::Base
  just_define_datetime_picker :starts_at
  just_define_datetime_picker :expires_at

  belongs_to :scene
  belongs_to :starting_sticker_pack, class_name: 'StickerPack'
  belongs_to :contest, -> {where(contest: true)}, class_name: 'GalleryTemplate'

  has_many :studio_sticker_packs, -> { order(:sort_order) }
  has_many :sticker_packs, through: :studio_sticker_packs
  has_many :stickers, through: :sticker_packs

  validates :name, uniqueness: true, presence: true
  validates :display_name, presence: true

  mount_uploader :image, ImageUploader
  mount_uploader :icon, StudioIconUploader

  scope :featured, -> {where(featured: true)}
end
