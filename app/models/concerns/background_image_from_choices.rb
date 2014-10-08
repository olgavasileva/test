module BackgroundImageFromChoices
  extend ActiveSupport::Concern

  included do
    before_create :generate_background_image_from_choices

    def background_image
      generate_background_image_from_choices if super.nil?

      super
    end

    private

    def generate_background_image_from_choices
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
