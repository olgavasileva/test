class StudioResponse < Response
  belongs_to :scene

  validates :scene, presence: true

  accepts_nested_attributes_for :scene

  def description
    "A Scene"
  end

  def csv_data
    property_keys = question.property_keys
    stickers = question.stickers

    line = []
    line << scene.try(:studio).try(:id)
    line << scene.try(:name)
    line << scene.try(:image).try(:url)

    sticker_ids = scene ? scene.stickers.map(&:id) : []
    property_totals = {}
    stickers.each do |sticker|
      line << sticker_ids.count(sticker.id)
    end

    scene.stickers.each do |sticker|
      # Accumulate property totals
      sticker.item_properties.each do |property|
        property_totals[property.key] ||= 0.0
        property_totals[property.key] += property.value.to_f
      end
    end if scene

    property_keys.each do |key|
      line << property_totals[key]
    end

    line
  end
end