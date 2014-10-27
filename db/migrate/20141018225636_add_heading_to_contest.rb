class AddHeadingToContest < ActiveRecord::Migration
  def change
    add_column :contests, :heading_markdown, :text
    add_column :contests, :heading_html, :text
  end
end
