ActiveAdmin.register Contest do
  menu parent: 'Surveys'

  permit_params :name, :key_question_id, :survey_id, :heading_markdown, :gallery_heading_markdown, :allow_anonymous_votes

  filter :name
  filter :survey

  index do
    column :id
    column :name
    column :key_question
    column "Contest URL" do |c|
      link_to "Contest Sign Up", contest_sign_up_url(c.uuid)
    end
    column "Gallery URL" do |c|
      link_to "Contest Gallery", contest_vote_url(c.uuid)
    end
    column :allow_anonymous_votes
    actions
  end

  show do |c|
    attributes_table do
      row :id
      row :name
      row :allow_anonymous_votes
      row "Heading" do
        c.heading_html.to_s.html_safe
      end
      row "Gallery Heading" do
        c.gallery_heading_html.to_s.html_safe
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
      f.input :allow_anonymous_votes
      f.input :heading_markdown
      f.input :gallery_heading_markdown
    end
    f.actions
  end

end
