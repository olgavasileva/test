class CreateBackgroundImagesAdUnits < ActiveRecord::Migration
  def change
    create_table :background_images_ad_units do |t|
      t.references :background_image, index: true
      t.references :ad_unit, index: true
      t.text :meta_data

      t.timestamps
    end
  end
end
