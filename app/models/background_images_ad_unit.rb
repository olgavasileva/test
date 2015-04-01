class BackgroundImagesAdUnit < ActiveRecord::Base
  belongs_to :background_image
  belongs_to :ad_unit
end
