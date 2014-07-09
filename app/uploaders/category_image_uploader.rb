# encoding: utf-8

class CategoryImageUploader < RetinaImageUploader

  #
  # Resize to fit the width and any height by supplying 0 as height
  #

  responsive_version :web, [310,0]
  responsive_version :device, [155,0]

end
