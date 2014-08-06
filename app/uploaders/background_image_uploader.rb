# encoding: utf-8

class BackgroundImageUploader < RetinaImageUploader

  #
  # Resize to fit the width and any height by supplying 0 as height
  #

  responsive_version :web, [320,320]
  responsive_version :device, [320,320]

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
