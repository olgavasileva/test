json.sticker_packs @sticker_packs do |pack|
  json.(pack, :id, :display_name, :updated_at)
  json.header_icon_url pack.header_icon.url
  json.sort_order next_index
end
