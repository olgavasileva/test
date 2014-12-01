class AddGettingStartedFieldsToStudio < ActiveRecord::Migration
  def change
    add_column :studios, :getting_started_markdown, :text
    add_column :studios, :getting_started_html, :text
  end
end
