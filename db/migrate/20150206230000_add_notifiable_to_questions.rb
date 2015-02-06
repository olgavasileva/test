class AddNotifiableToQuestions < ActiveRecord::Migration
  def change
    change_table :questions do |t|
      t.boolean :notifying, default: false
    end
  end
end
