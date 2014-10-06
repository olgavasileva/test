class PercentChoice < Choice
  has_and_belongs_to_many :responses, join_table: :percent_choices_response
end