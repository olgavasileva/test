ActiveAdmin.register Contest do
  menu parent: 'Surveys'

  permit_params :name, :key_question_id, :survey_id
end
