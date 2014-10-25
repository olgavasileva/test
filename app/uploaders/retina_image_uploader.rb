# encoding: utf-8

#
# Base CarrierWave uploader for generating web and device files of standard and @2x sizes.
# Inherit from this class and call responsive_version with a version name and standard_size (1x size)

class RetinaImageUploader < UploaderBase

  include CarrierWave::RMagick

  # This generates 2 versions for the given name - e.g. :web and :retina_web
  # Use these with responsive_image_tag, which will look for the retina_* version.
  def self.responsive_version name = :web, standard_size = [320,0], process = :resize_and_pad
    version name do
      process process => standard_size
    end

    version "retina_#{name}" do
      process process => standard_size.map{|s| s*2}

      # returns @2x for retina version
      def full_filename(for_file)
        super.tap do |file_name|
          file_name.gsub!(/\.(?=[^.]*$)/, '@2x.').gsub!('retina_', '')
        end
      end
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
