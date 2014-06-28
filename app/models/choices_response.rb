class ChoicesResponse < ActiveRecord::Base
  belongs_to :choice, class_name: "MultipleChoice", foreign_key: :multiple_choice_id
  belongs_to :response, class_name:"MultipleChoiceResponse", foreign_key: :multiple_choice_response_id
end