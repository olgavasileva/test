json.sticker_packs @sticker_packs do |pack|
  json.partial! 'sticker_pack', sticker_pack:pack
  json.sort_order next_index
end
