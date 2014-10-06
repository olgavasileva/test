class AddLongitudeAndLatitudeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :longitude, :string
    add_column :users, :latitude, :string
  end
end
