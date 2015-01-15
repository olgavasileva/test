ActiveAdmin.register Language do
  menu parent: 'Studios'

  permit_params :name, translations_attributes: [:id, :key, :value, :_destroy]

  form partial: "form"

  show do |l|
    panel "Translations" do
      table_for l.translations do
        column :key
        column :value
      end
    end
  end
end