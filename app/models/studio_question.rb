class StudioQuestion < Question
  belongs_to :studio
  has_many :responses, class_name:"StudioResponse", foreign_key: :question_id

  validates :studio, presence: true

  # Used for csv export
  def property_keys
    ItemProperty.order(:key).map(&:key).uniq
  end

  # Used for csv export
  def stickers
    studio.stickers.order('stickers.priority ASC') # NOTE there are other sorts on the studio.sticker relation in the models
  end

  def csv_columns
    columns = [title, :studio_id, "cereal name", :image]
    stickers.each do |sticker|
      columns << sticker.display_name
    end
    property_keys.each do |key|
      columns << key
    end

    columns
  end
end