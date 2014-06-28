class StarChoice < Choice
  has_and_belongs_to_many :responses, join_table: :star_choices_response
end