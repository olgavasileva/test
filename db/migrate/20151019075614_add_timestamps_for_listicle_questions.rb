class AddTimestampsForListicleQuestions < ActiveRecord::Migration
  def up
    change_table :listicle_questions do |t|
      t.timestamps
    end
    Listicle.all.includes(:questions).find_each do |listicle|
      listicle.questions.each_with_index do |question, i|
        question.update(created_at: listicle.created_at + i.seconds, updated_at: listicle.created_at + i.seconds)
      end
    end
  end

  def down
    remove_columns :listicle_questions, :created_at, :updated_at
  end
end
