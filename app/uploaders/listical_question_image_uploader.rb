class ListicalQuestionImageUploader < UploaderBase
  include CarrierWave::RMagick

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def model
    NullModel.new
  end
end

class NullModel
  def id
    self.object_id
  end
end