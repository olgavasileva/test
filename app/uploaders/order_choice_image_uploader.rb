# encoding: utf-8

class OrderChoiceImageUploader < RetinaImageUploader
  process resize_to_fill: [320, 80]

  version :web do
    process resize_to_fill: [320, 80]
  end

  version :device do
    process resize_to_fill: [320, 80]
  end

end
