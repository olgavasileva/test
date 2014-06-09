class AddSliderToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :slider, :integer
  end
end
