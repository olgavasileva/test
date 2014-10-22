ActiveAdmin.register QuestionsSurvey do
  belongs_to :survey

  permit_params :question_id

  config.sort_order = 'position_asc' # assumes you are using 'position' for your acts_as_list column
  sortable # creates the controller action which handles the sorting

  index do
    sortable_handle_column
    column :question
    actions
  end

  form do |f|
    f.inputs do
      f.input :question
      f.input :survey, as: :hidden
    end
    f.actions
  end

  show do |qs|
    attributes_table do
      row :question
      row :created_at
      row :updated_at
    end
  end

end