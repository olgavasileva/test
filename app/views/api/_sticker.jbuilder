json.(sticker, :id, :display_name, :mirrorable, :type, :image_url, :image_width, :image_height)
json.sort_order sticker.priority
json.tags sticker.tag_list.map { |t| "##{t}" }
json.image_thumb_url sticker.image.thumb.url
json.properties Hash[sticker.item_properties.map{|prop| [prop.key, prop.value]}]
