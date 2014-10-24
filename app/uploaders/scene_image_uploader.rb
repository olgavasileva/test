# encoding: utf-8
class SceneImageUploader < UploaderBase

  include CarrierWave::RMagick

  def default_url
    ActionController::Base.helpers.asset_path "fallback/sample_studio.jpg"
  end

  version :thumb do
    process :resize_to_fill => [400,275]
  end

  version :large do
    process :resize_to_fill => [2048,1408]
  end

end
