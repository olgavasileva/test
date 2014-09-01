object @sticker
attributes :id, :display_name, :mirrorable, :type, :image_url, :image_width, :image_height, :properties
attributes sort_order: :priority
node(:tags) {|s| s.tag_list}
node(:image_thumb_url) {|s| s.image.thumb.url}
# node(:properties) do
#   object.item_properties.each do |property|
#     node(property.key) {property.value}
#   end
# end