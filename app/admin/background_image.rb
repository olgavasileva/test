ActiveAdmin.register BackgroundImage do
  menu false
  actions :show, :edit, :update

  show do |image|
    columns do
      column do
        imgs = %w{web_image_url device_image_url retina_device_image_url}
        imgs.each do |img|
          panel img.titleize do
            url = image.send(img)
            c  = image_tag url, class: 'panel-image'
            c += link_to('View', url, target: '_blank')
            c.html_safe
          end
        end
      end

      column do
        panel 'Meta data' do
          attributes_table_for image do
            units = AdUnit.order(width: :asc, height: :asc).pluck(:name)
            units.each do |unit|
              row(unit) do
                value = image.ad_unit_info(unit).try(:meta_data)
                "<code>#{JSON.pretty_generate(value)}</code>".html_safe if value
              end
            end
          end
        end
      end
    end
  end

  form do |f|
    unless f.object.meta_data_json.present?
      f.object.meta_data_json = Hashie::Mash.new
    end

    f.inputs 'Background Image' do
      f.semantic_fields_for :meta_data_json do |meta|

        units = AdUnit.order(width: :asc, height: :asc).pluck(:name)
        raise meta
        units.each do |unit|
          value = f.object.ad_unit_info(unit).try(:value)
          value = value.present? ? value.to_json : ''
          meta.input unit, as: :text, label: unit, value: value.html_safe
        end
      end
    end
  end
end
