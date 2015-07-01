ActiveAdmin.register Survey do
  menu parent: 'Surveys'

  permit_params :name, :username, :thank_you_markdown, :thank_you_html, :theme_id, contest_ids: []

  filter :id
  filter :user_username, as: :string, label: "Username"
  filter :uuid
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :user do |survey|
      link_to survey.user.username, admin_users_path(survey.user)
    end
    column :name
    column :uuid
    column "Theme" do |survey|
      survey.theme.title
    end
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

  member_action :remove_question, method: :delete do
    query = resource.questions_surveys.where(question_id: params[:question_id])
    query.delete_all
    redirect_to resource_path, notice: "Question removed from survey."
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :theme, as: :select
      f.input :username
      f.input :contests, as: :check_boxes, label_method: :name
      f.input :thank_you_markdown, hint: "You can use markdown to style this text.  Note, this is used in new ad units, but not in former embeddable units."
      f.input :thank_you_html, hint: "Editing this overrides anythin in the markdown"
    end
    f.actions
  end

  show do |survey|
    columns do
      column span: 2 do
        panel 'Survey Details' do
          attributes_table_for survey do
            row :uuid
            row :name
            row :user
            row :theme
            row :thank_you_html do
              survey.try(:thank_you_html).try(:html_safe)
            end
          end
        end

        panel 'Survey Questions' do
          x = survey.questions.to_a
          total_views = survey.questions.sum(:view_count)
          total_responses = survey.questions.map{|q|q.response_count}.sum
          x << OpenStruct.new(id: nil, title: "TOTAL", type: nil,  view_count: total_views,  response_count: total_responses)
          table_for x do
            column :id
            column(:title) { |q| q.id ? link_to(q.title, admin_question_path(q)) : q.title  }
            column(:type) { |q| status_tag q.type, :ok if q.id }
            column(:views, class: 'aa-number') { |q| number_with_delimiter q.view_count }
            column(:responses, class: 'aa-number') { |q| number_with_delimiter q.response_count }
            column(:actions) do |q|
              if q.id
                url = remove_question_admin_survey_path(survey, question_id: q.id)
                content  = link_to 'View', admin_question_path(q)
                content += ' / '
                content += link_to 'Remove', url, method: :delete, data: {confirm: 'Are you sure?'}
                content.html_safe
              end
            end
          end
        end

        panel 'Embeddables' do
          attributes_table_for survey do
            AdUnit.all.map do |ad_unit|
              row ad_unit.name.humanize.titleize do
                "<label>Script</label><div><textarea rows='7' style='width: 100%' onmouseenter='$(this).select()'>#{survey.script request, ad_unit}</textarea></div>".html_safe +
                "<label>iFrame</label><div><input style='width: 100%' onmouseenter='$(this).select()' value='#{survey.iframe request, ad_unit}'></div>".html_safe +
                survey.iframe(request, ad_unit).html_safe
              end
            end
          end
        end
      end
    end
  end

end
