json.backgrounds @backgrounds do |bg|
  json.partial! 'sticker', sticker:bg
end

json.stickers @stickers do |s|
  json.partial! 'sticker', sticker:s
end
