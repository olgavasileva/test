module BackgroundImageFromChoices
  extend ActiveSupport::Concern

  included do
    before_validation :generate_background_image_from_choices

    private

    def generate_background_image_from_choices
      return unless background_image.nil?

      choice_images = choices[0..3].map { |c| c.background_image.image.url }

      return if choice_images.empty?

      if self.kind_of?(OrderQuestion)
        montage = Magick::ImageList.new(*choice_images).montage do |m|
          m.background_color = '#a4a5a9'
          m.tile = '1x4'
          m.geometry = '320x80+0+0'
        end
      else
        montage = Magick::ImageList.new(*choice_images).montage do |m|
          m.background_color = '#a4a5a9'
          m.tile = '2x2'
          m.geometry = '160x160+0+0'
        end
      end

      file = Tempfile.new(['question_image', '.jpg'])

      montage.write(file.path)

      self.background_image = QuestionImage.new(image: file)
    end
  end
end
