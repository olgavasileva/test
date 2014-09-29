class StickerPackSticker < ActiveRecord::Base
  belongs_to :sticker_pack
  belongs_to :sticker

  before_create :set_sort_order_value

  private

  def set_sort_order_value
    if self.sort_order.nil?
      self.sort_order = sticker.priority
    end
  end
end