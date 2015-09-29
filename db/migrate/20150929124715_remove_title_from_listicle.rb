class RemoveTitleFromListicle < ActiveRecord::Migration
  def change
    remove_column :listicles, :title, :text
    rename_column :listicles, :header, :intro
  end
end
