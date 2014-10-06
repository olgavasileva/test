class ChangeStringToTextForSomeFields < ActiveRecord::Migration
  def change
    change_column :questions, :title, :text
    change_column :choices, :title, :text
    change_column :responses, :text, :text
    change_column :responses, :comment, :text
  end
end
