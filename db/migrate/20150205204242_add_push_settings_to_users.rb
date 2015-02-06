class AddPushSettingsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :push_on_question_asked, default: -1
      t.integer :push_on_question_answered, default: -1
    end
  end
end
