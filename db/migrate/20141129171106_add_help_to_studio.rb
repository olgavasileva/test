class AddHelpToStudio < ActiveRecord::Migration
  def change
    add_column :studios, :help_html, :text
    add_column :studios, :help_markdown, :text
  end
end
