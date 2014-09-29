class StudioStickerPack < ActiveRecord::Base
  belongs_to :studio
  belongs_to :sticker_pack


  before_create :set_sort_order_value

  private

  def set_sort_order_value
    if self.sort_order.nil?
      self.sort_order = self.class.where(studio_id: self.studio_id).maximum(:sort_order).to_i + 1
    end
  end
end