class AddGalleryHeadingToContest < ActiveRecord::Migration
  def change
    add_column :contests, :gallery_heading_markdown, :text
    add_column :contests, :gallery_heading_html, :text
  end
end
