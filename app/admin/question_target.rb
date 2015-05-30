ActiveAdmin.register QuestionTarget do
  belongs_to :user, class_name: "Respondent"
  config.sort_order = "created_at_desc"

  # permit_params :published_at, :hidden, :hidden_reason, :hidden_at

  index do
    column :id
    column "Question ID" do |fi|
      link_to fi.question.id, admin_question_path(fi.question)
    end
    column "Question" do |fi|
      link_to fi.question.title, admin_question_path(fi.question)
    end
    column :relevance
    column :created_at

    actions
  end

  form do |f|
    f.inputs do
      f.input :created_at
    end
    f.actions
  end

end