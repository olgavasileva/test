ActiveAdmin.register Localization, as: "Studio Localizations" do
  menu parent: 'Studios'

  permit_params :localizable_id, :language_id

  index do
    column :id
    column :localizable_type
    column :localizable
    column :language
    actions
  end

  show do |l|
    attributes_table_for l do
      row :id
      row :localizable_type
      row :localizable
      row :language
      row :created_at
      row :udpated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :localizable, collection: Studio.all, label: "Studio"
      f.input :language
    end
    f.actions
  end
end