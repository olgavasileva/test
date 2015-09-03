class ListicalToListicle < ActiveRecord::Migration
  def change
    rename_column :listical_questions, :listical_id, :listicle_id
    rename_table :listicals, :listicles
    rename_table :listical_questions, :listicle_questions
    rename_table :listical_responses, :listicle_responses
  end
end
