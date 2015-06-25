ActiveAdmin.register EmbeddableUnitTheme do
  menu parent: 'Surveys'

  permit_params :title, :main_color, :user_id, :color1, :color2

  filter :user
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
end
