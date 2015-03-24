class YesNoChoice < TextChoice
  belongs_to :question, class_name:"YesNoQuestion", inverse_of: :yes_no_choices
end
