class RemoveImageFromCategory < ActiveRecord::Migration
  def up
    remove_column :categories, :image
    remove_column :categories, :category_type
  end

  def down
    add_column :categories, :image, :string
    add_column :categories, :category_type, :string
  end
end
