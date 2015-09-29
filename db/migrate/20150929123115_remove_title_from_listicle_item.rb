class RemoveTitleFromListicleItem < ActiveRecord::Migration
  def change
    remove_column :listicle_questions, :title, :string
  end
end
