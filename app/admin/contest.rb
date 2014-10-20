ActiveAdmin.register Contest do
  menu parent: 'Surveys'

  permit_params :name, :key_question_id, :survey_id, :heading_markdown

  index do
    column :id
    column :name
    column :key_question
    column "Sign Up URL" do |c|
      contest_sign_up_url(c.uuid)
    end
    actions
  end

  show do |c|
    attributes_table do
      row :id
      rows :name
      row "Heading" do
        c.heading_html.html_safe
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :survey
      f.input :key_question, collection: f.object.questions
      f.input :name
      f.input :heading_markdown
    end
    f.actions
  end

end
