ActiveAdmin.register InappropriateFlag do
  belongs_to :inappropriate_question, class_name: :question

  index do
    column :reason
    column :user
    actions
  end
end
