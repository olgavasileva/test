json.image_id image.try(:id)
json.image_url image.try(:device_image_url)

json.image_meta_data do
  infos = image.try(:ad_unit_infos).try(:includes, :ad_unit).try(:to_a)
  if infos && !infos.empty?
    infos.each do |info|
      json.set! info.ad_unit.name, info.meta_data
    end
  else
    json.null!
  end
end
