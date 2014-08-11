class ChangeChoiceImageToChoiceBackgroundImageId < ActiveRecord::Migration
  def up
    add_column :choices, :background_image_id, :integer
    remove_column :choices, :image
  end

  def down
    add_column :choices, :image, :string
    remove_column :choices, :background_image_id
  end
end
