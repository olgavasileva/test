ActiveAdmin.register Survey do
  menu parent: 'Surveys'

  permit_params :name, questions_surveys_attributes: [:id, :question_id, :_destroy]

  sidebar "Questions" do
    if params[:id]
      survey = Survey.find params[:id]
      link_to pluralize(survey.questions_surveys.count, 'Question'), admin_survey_questions_surveys_path(survey)
    end
  end

  index do
    column :id
    column :user do |survey|
      link_to survey.user.username, admin_users_path(survey.user)
    end
    column :name
    column :uuid
    column "Questions" do |survey|
      link_to pluralize(survey.questions_surveys.count, 'Question'), admin_survey_questions_surveys_path(survey)
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :user_id, label: 'User ID (owner)'
      f.input :contests, as: :check_boxes, label_method: :name
    end
    f.actions
  end

end
