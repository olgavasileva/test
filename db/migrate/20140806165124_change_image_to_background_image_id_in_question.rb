class ChangeImageToBackgroundImageIdInQuestion < ActiveRecord::Migration
  def up
    add_column :questions, :background_image_id, :integer
    add_index :questions, :background_image_id
    remove_column :questions, :image
  end

  def down
    add_column :questions, :image, :string
    remove_column :questions, :background_image_id
  end
end
