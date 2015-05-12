ActiveAdmin.register BackgroundImage do
  menu false
  actions :show, :edit, :update

  permit_params do
    [meta_data_json: AdUnit.pluck(:name)]
  end

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
    f.object.meta_data_json = Hashie::Mash.new(f.object.meta_data_json)

    html = f.semantic_errors()
    f.inputs 'Background Image' do
      f.semantic_fields_for :meta_data_json do |meta|
        units = AdUnit.order(width: :asc, height: :asc).pluck(:name)
        units.map do |unit|
          value = f.object.ad_unit_info(unit).try(:meta_data)
          value = value.present? ? value.to_json : ''
          meta.input unit, as: :string, label: unit, required: false, input_html: {value: value}
        end.join(' ').html_safe # Formtastic is so awesome
      end
    end

    # Formtastic is so awesome. This makes absolutely no sense. `html` doesn't
    # even contain the inputs, yet they're rendered
    (html + f.submit).html_safe
  end
end
