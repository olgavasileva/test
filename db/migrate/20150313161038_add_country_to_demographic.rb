class AddCountryToDemographic < ActiveRecord::Migration
  def up
    add_column :demographics, :country, :string
    add_index :demographics, :country


    begin
      Demographic.reset_column_information
      Demographic.where.not(ip_address:nil).find_each do |d|
        d.update_attribute :country, d.country_code
      end
    rescue
    end
  end

  def down
    remove_index :demographics, :country
    remove_column :demographics, :country
  end
end
