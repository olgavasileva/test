module BackgroundImageFromChoices
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_background_image_from_choices

    private

    def generate_background_image_from_choices
      return unless background_image.nil?

      choice_images = choices[0..3].map { |c| c.background_image.image.url }

      return if choice_images.empty?

      montage = Magick::ImageList.new(*choice_images).montage do |m|
        m.tile = '2x2'
      end

      file = Tempfile.new(['question_image', '.jpg'])

      montage.write(file.path)

      self.background_image = QuestionImage.create!(image: file)
    end
  end
end
