# encoding: utf-8

class OrderChoiceImageUploader < RetinaImageUploader
  process resize_to_fill: [320, 80]

  responsive_version :web, [320,80], :resize_to_fill
  responsive_version :device, [320,80], :resize_to_fill
end
