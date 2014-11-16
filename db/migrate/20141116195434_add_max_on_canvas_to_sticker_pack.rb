class AddMaxOnCanvasToStickerPack < ActiveRecord::Migration
  def change
    add_column :sticker_packs, :max_on_canvas, :integer
  end
end
