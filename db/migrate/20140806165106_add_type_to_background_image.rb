class AddTypeToBackgroundImage < ActiveRecord::Migration
  def change
    add_column :background_images, :type, :string
  end
end
