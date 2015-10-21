class AddScriptsForListicleQuestions < ActiveRecord::Migration
  def change
    add_column :listicle_questions, :script, :text
  end
end
