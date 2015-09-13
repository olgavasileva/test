class ExtendListicleFieldSizes < ActiveRecord::Migration
  def change
    change_column :listicles, :title, :text
  end
end
