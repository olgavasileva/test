# encoding: utf-8

class ChoiceImageUploader < RetinaImageUploader

  responsive_version :web, [160,160], :resize_to_fill
  responsive_version :device, [160,160], :resize_to_fill

end
