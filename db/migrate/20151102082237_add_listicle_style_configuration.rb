class AddListicleStyleConfiguration < ActiveRecord::Migration
  def change
    change_table :listicles do |t|
      t.string :item_separator_color
      t.string :vote_count_color
      t.string :arrows_default_color
      t.string :arrows_on_hover_color
      t.string :arrows_selected_color
    end
  end
end
