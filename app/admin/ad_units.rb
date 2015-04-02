ActiveAdmin.register AdUnit do
  menu parent: 'Surveys'

  permit_params :name, :width, :height, :json_meta_data

  filter :name
  filter :width
  filter :height

  index do
    column :id
    column :name
    column :width
    column :height
    actions
  end

  show do |unit|
    attributes_table do
      rows :id, :name, :width, :height
      row :default_meta_data do
        html  = "<code>"
        if unit.default_meta_data?
          html += JSON.pretty_generate(unit.default_meta_data)
        end
        html += "</code>"
        html.html_safe
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :width
      f.input :height
      f.input :json_meta_data,
        as: :text,
        label: 'Default Metadata',
        input_html: {value: (f.object.default_meta_data? ? JSON.dump(f.object.default_meta_data) : '') }
    end

    f.actions
  end
end
