ActiveAdmin.register AdUnit do
  menu parent: 'Surveys'

  permit_params :name, :width, :height, :default_meta_data

  filter :name
  filter :width
  filter :height
end