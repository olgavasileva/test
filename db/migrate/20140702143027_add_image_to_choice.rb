class AddImageToChoice < ActiveRecord::Migration
  def change
    add_column :choices, :image, :string
  end
end
