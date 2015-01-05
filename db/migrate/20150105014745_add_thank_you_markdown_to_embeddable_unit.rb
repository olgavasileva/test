class AddThankYouMarkdownToEmbeddableUnit < ActiveRecord::Migration
  def change
    add_column :embeddable_units, :thank_you_markdown, :text
    add_column :embeddable_units, :thank_you_html, :text
  end
end
