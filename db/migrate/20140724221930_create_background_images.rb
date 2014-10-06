class CreateBackgroundImages < ActiveRecord::Migration
  def change
    create_table :background_images do |t|
      t.string :image
      t.integer :position

      t.timestamps
    end
  end
end
