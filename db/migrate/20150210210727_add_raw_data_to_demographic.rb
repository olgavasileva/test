class AddRawDataToDemographic < ActiveRecord::Migration
  def change
    add_column :demographics, :raw_data, :text
  end
end
