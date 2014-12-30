ActiveAdmin.register EmbeddableUnit do
  menu parent: 'Surveys'

  permit_params :survey_id

  form do |f|
    f.inputs do
      f.input :survey
    end
    f.actions
  end
end