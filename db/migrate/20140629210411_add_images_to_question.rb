class AddImagesToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :info_image, :string
  end
end
