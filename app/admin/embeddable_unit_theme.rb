ActiveAdmin.register EmbeddableUnitTheme do
  menu parent: 'Surveys'

  permit_params :title, :main_color, :user_id, :color1, :color2

  filter :user_username, as: :string, label: 'Username'
  filter :title
  filter :main_color
  filter :color1
  filter :color2

  index do
    selectable_column
    id_column
    column :title
    column :user
    column 'Is Default?' do |theme|
      !theme.user.present?
    end
    column :main_color
    column :color1
    column :color2
    actions
  end

  form do |f|
    f.inputs do
      f.input :user_id, as: :number
      f.input :title
      f.input :main_color
      f.input :color1
      f.input :color2
    end
    f.actions
  end
end
