# encoding: utf-8

class OrderChoiceImageUploader < RetinaImageUploader
  responsive_version :web, [320,80]
  responsive_version :device, [320,80]
end
