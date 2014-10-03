class StickerImageUploader < UploaderBase

  include CarrierWave::RMagick

  version :thumb do
    process :manual_crop
  end

  def manual_crop
    if model.class == Background
      resize_to_fill(200, 200)
    else
      resize_to_limit(200,200)
    end
  end

  def geometry
    @geometry ||= get_geometry
  end

  def get_geometry
    begin
      if @file
        #If the file is new, it cannot be read with url
        img = ::Magick::Image::read((@file.url rescue @file.path)).first
        geometry = { width: img.columns, height: img.rows }
      end
    rescue
      nil
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    ActionController::Base.helpers.asset_path("missing.png")
  end
end
