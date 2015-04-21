ActiveAdmin.register Survey do
  menu parent: 'Surveys'

  permit_params :name, :username, :thank_you_markdown, contest_ids: []

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

  # Set a default username for the form based on currently logged in standard user, or the first user if none logged in
  controller do
    def build_new_resource
      r = super
      r.username ||= current_user.username || Respondent.first.username
      r
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :username
      f.input :contests, as: :check_boxes, label_method: :name
      f.input :thank_you_markdown, hint: "You can use markdown to style this text.  Note, this is used in new ad units, but not in former embeddable units."
    end
    f.actions
  end

  show do |survey|
    attributes_table do
      row :uuid
      row :name
      row :user
      row :thank_you_html do
        survey.thank_you_html.html_safe
      end
    end
  end

end
