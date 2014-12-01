class AddStandAloneHeaderToStudio < ActiveRecord::Migration
  def change
    add_column :studios, :stand_alone_studio_header_html, :text
    add_column :studios, :stand_alone_studio_header_markdown, :text
  end
end
