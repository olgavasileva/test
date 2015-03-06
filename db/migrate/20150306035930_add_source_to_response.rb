class AddSourceToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :source, :string
    add_index :responses, :source
  end
end
