class ListicleViewCount < ActiveRecord::Migration
  def change
    add_column :listicles, :view_count, :integer, null: false, default: 0
  end
end
