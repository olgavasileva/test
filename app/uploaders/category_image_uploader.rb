# encoding: utf-8

class CategoryImageUploader < RetinaImageUploader

  #
  # Resize to fit the width and any height by supplying 0 as height
  #

  responsive_version :web, [320,320]
  responsive_version :device, [320,320]

end
