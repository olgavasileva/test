class RemoveInfoImageFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :info_image
  end

  def down
    add_column :questions, :info_image, :string
  end
end
