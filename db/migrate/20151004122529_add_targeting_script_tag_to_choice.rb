class AddTargetingScriptTagToChoice < ActiveRecord::Migration
  def change
    add_column :choices, :targeting_script, :text
  end
end
