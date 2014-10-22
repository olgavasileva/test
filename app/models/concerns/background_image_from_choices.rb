module BackgroundImageFromChoices
  extend ActiveSupport::Concern

  included do
    before_validation :generate_background_image_from_choices

    private

    def generate_background_image_from_choices
      return unless background_image.nil?

      choice_images = choices[0..3].map { |c| c.background_image.image.url }

      return if choice_images.empty?

      tile, geometry = if self.kind_of?(OrderQuestion)
        ['1x4','160x80+0+0']
      else
        ['2x2','160x160+0+0']
      end

      montage = Magick::ImageList.new(*choice_images).montage do |m|
        m.tile = tile
        m.background_color = '#a4a5a9'
        m.geometry = geometry
      end

      file = Tempfile.new(['question_image', '.jpg'])

      montage.write(file.path)

      self.background_image = QuestionImage.new(image: file)
    end
  end
end
